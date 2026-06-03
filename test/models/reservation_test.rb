require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  def setup
    @court = courts(:cancha_a)
    @user  = users(:member)
    @base  = 3.days.from_now.change(hour: 10, min: 0, sec: 0, usec: 0)
  end

  def valid_attrs
    {
      court: @court, user: @user,
      starts_at: @base, ends_at: @base + 1.hour,
      total_amount: 1000, deposit_amount: 300
    }
  end

  # ─── Validaciones básicas ────────────────────────────────────────────────────

  test "reserva válida con todos los campos correctos" do
    assert Reservation.new(valid_attrs).valid?
  end

  test "requiere starts_at" do
    r = Reservation.new(valid_attrs.merge(starts_at: nil))
    assert_not r.valid?
    assert r.errors[:starts_at].any?
  end

  test "requiere ends_at" do
    r = Reservation.new(valid_attrs.merge(ends_at: nil))
    assert_not r.valid?
    assert r.errors[:ends_at].any?
  end

  test "total_amount debe ser mayor a 0" do
    r = Reservation.new(valid_attrs.merge(total_amount: 0))
    assert_not r.valid?
    assert r.errors[:total_amount].any?
  end

  test "deposit_amount puede ser 0" do
    assert Reservation.new(valid_attrs.merge(deposit_amount: 0)).valid?
  end

  # ─── ends_after_starts ──────────────────────────────────────────────────────

  test "ends_at anterior a starts_at es inválido" do
    r = Reservation.new(valid_attrs.merge(ends_at: @base - 30.minutes))
    assert_not r.valid?
    assert r.errors[:ends_at].any?
  end

  test "ends_at igual a starts_at es inválido" do
    r = Reservation.new(valid_attrs.merge(ends_at: @base))
    assert_not r.valid?
    assert r.errors[:ends_at].any?
  end

  # ─── within_max_duration ────────────────────────────────────────────────────

  test "superar max_duration_minutes (120 min) es inválido" do
    r = Reservation.new(valid_attrs.merge(ends_at: @base + 3.hours))
    assert_not r.valid?
    assert r.errors[:ends_at].any?
  end

  test "duración exacta al máximo es válida" do
    r = Reservation.new(valid_attrs.merge(ends_at: @base + 120.minutes))
    assert r.valid?, r.errors.full_messages.to_sentence
  end

  # ─── not_too_far_in_advance ─────────────────────────────────────────────────

  test "más de 30 días en adelante es inválido" do
    far = 31.days.from_now.change(hour: 10, min: 0, sec: 0, usec: 0)
    r = Reservation.new(valid_attrs.merge(starts_at: far, ends_at: far + 1.hour))
    assert_not r.valid?
    assert r.errors[:starts_at].any?
  end

  test "exactamente 30 días en adelante es válido" do
    at_limit = 30.days.from_now.change(hour: 10, min: 0, sec: 0, usec: 0)
    r = Reservation.new(valid_attrs.merge(starts_at: at_limit, ends_at: at_limit + 1.hour))
    assert r.valid?, r.errors.full_messages.to_sentence
  end

  # ─── no_overlap ─────────────────────────────────────────────────────────────

  test "no permite solapamiento con reserva activa en la misma cancha" do
    existing = Reservation.create!(valid_attrs)
    overlap = Reservation.new(valid_attrs.merge(
      starts_at: @base + 30.minutes, ends_at: @base + 90.minutes
    ))
    assert_not overlap.valid?
    assert overlap.errors[:base].any?
  end

  test "solapamiento parcial al inicio también es detectado" do
    existing = Reservation.create!(valid_attrs)
    overlap = Reservation.new(valid_attrs.merge(
      starts_at: @base - 30.minutes, ends_at: @base + 30.minutes
    ))
    assert_not overlap.valid?
    assert overlap.errors[:base].any?
  end

  test "permite reserva consecutiva (fin de una == inicio de otra)" do
    Reservation.create!(valid_attrs)
    consecutive = Reservation.new(valid_attrs.merge(
      starts_at: @base + 1.hour, ends_at: @base + 2.hours
    ))
    assert consecutive.valid?, consecutive.errors.full_messages.to_sentence
  end

  test "permite solaparse con reserva cancelada" do
    existing = Reservation.create!(valid_attrs)
    existing.update_column(:status, "cancelled")
    assert Reservation.new(valid_attrs).valid?
  end

  test "solapamiento en cancha distinta no interfiere" do
    Reservation.create!(valid_attrs)
    other = Reservation.new(valid_attrs.merge(court: courts(:cancha_b)))
    assert other.valid?, other.errors.full_messages.to_sentence
  end

  # ─── not_blocked ────────────────────────────────────────────────────────────

  test "reserva dentro de un bloqueo de cancha es inválida" do
    block = @court.court_blocks.create!(
      starts_at: @base - 30.minutes, ends_at: @base + 90.minutes, reason: "Test"
    )
    assert_not Reservation.new(valid_attrs).valid?
  end

  # ─── confirmed_requires_deposit — reserva online ────────────────────────────

  test "reserva online no puede confirmarse sin seña pagada" do
    r = Reservation.new(valid_attrs)
    r.status = "confirmed"
    assert_not r.valid?
    assert r.errors[:base].any?
  end

  test "reserva online confirma cuando existe deposit_charge" do
    r = Reservation.create!(valid_attrs)
    Charge.create!(
      user: @user, reservation: r, amount: 300, concept: "Seña test",
      charge_type: :rental, payment_method: :cash, date: Date.today, is_deposit: true
    )
    r.reload
    r.status = "confirmed"
    assert r.valid?, r.errors.full_messages.to_sentence
  end

  # ─── confirmed_requires_deposit — walk-in ───────────────────────────────────

  test "walk-in no puede confirmarse sin balance_charge" do
    r = Reservation.new(valid_attrs.merge(deposit_amount: 0))
    r.status = "confirmed"
    assert_not r.valid?
    assert_match "cobro registrado", r.errors[:base].join
  end

  test "walk-in puede confirmarse con balance_charge presente" do
    r = Reservation.create!(valid_attrs.merge(deposit_amount: 0))
    r.create_balance_charge!(
      user: @user, amount: 1000, concept: "Alquiler test",
      charge_type: :rental, payment_method: :cash, date: Date.today
    )
    r.status = "confirmed"
    assert r.valid?, r.errors.full_messages.to_sentence
  end

  # ─── AASM — máquina de estados ──────────────────────────────────────────────

  test "estado inicial es pending" do
    assert Reservation.new(valid_attrs).pending?
  end

  test "puede cancelarse desde pending" do
    r = Reservation.create!(valid_attrs)
    assert r.may_cancel?
  end

  test "no puede cancelarse desde finished" do
    r = Reservation.new(valid_attrs)
    r.status = "finished"
    assert_not r.may_cancel?
  end

  test "puede finalizar desde confirmed" do
    r = Reservation.new(valid_attrs)
    r.status = "confirmed"
    assert r.may_finish?
  end

  test "puede finalizar desde in_progress" do
    r = Reservation.new(valid_attrs)
    r.status = "in_progress"
    assert r.may_finish?
  end
end
