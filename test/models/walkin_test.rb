require "test_helper"

class WalkinTest < ActiveSupport::TestCase
  def setup
    @court = courts(:cancha_a)
    @user  = users(:member)
    @base  = 4.days.from_now.change(hour: 14, min: 0, sec: 0, usec: 0)
  end

  def pending_walkin
    Reservation.create!(
      court: @court, user: @user,
      starts_at: @base, ends_at: @base + 1.hour,
      total_amount: 800, deposit_amount: 0
    )
  end

  # ─── confirmed_requires_deposit para walk-ins ────────────────────────────────

  test "walk-in en pending es válido sin cobro" do
    assert pending_walkin.pending?
  end

  test "walk-in no puede confirmarse sin balance_charge" do
    r = pending_walkin
    r.status = "confirmed"
    assert_not r.valid?
    assert_match "cobro registrado", r.errors[:base].join
  end

  test "walk-in puede confirmarse después de crear el balance_charge" do
    r = pending_walkin
    r.create_balance_charge!(
      user: @user, amount: 800, concept: "Alquiler walk-in",
      charge_type: :rental, payment_method: :cash, date: Date.today
    )
    r.status = "confirmed"
    assert r.valid?, r.errors.full_messages.to_sentence
  end

  test "confirm! retorna true con balance_charge y cambia estado" do
    r = pending_walkin
    r.create_balance_charge!(
      user: @user, amount: 800, concept: "Alquiler walk-in",
      charge_type: :rental, payment_method: :cash, date: Date.today
    )
    result = r.confirm!
    assert result, "confirm! debería retornar true"
    assert r.confirmed?
  end

  test "confirm! retorna false sin balance_charge y no cambia estado" do
    r = pending_walkin
    result = r.confirm!
    assert_not result, "confirm! debería retornar false sin cobro"
    assert r.pending?, "el estado debería permanecer pending"
  end

  # ─── Solapamiento a nivel de modelo ─────────────────────────────────────────

  test "dos walk-ins en la misma cancha y horario: el modelo rechaza el segundo" do
    pending_walkin
    duplicate = Reservation.new(
      court: @court, user: @user,
      starts_at: @base, ends_at: @base + 1.hour,
      total_amount: 800, deposit_amount: 0
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:base].any?
  end

  test "walk-in en cancha distinta al mismo horario es válido" do
    pending_walkin
    other = Reservation.new(
      court: courts(:cancha_b), user: @user,
      starts_at: @base, ends_at: @base + 1.hour,
      total_amount: 800, deposit_amount: 0
    )
    assert other.valid?, other.errors.full_messages.to_sentence
  end

  test "walk-in consecutivo en la misma cancha es válido" do
    pending_walkin
    consecutive = Reservation.new(
      court: @court, user: @user,
      starts_at: @base + 1.hour, ends_at: @base + 2.hours,
      total_amount: 800, deposit_amount: 0
    )
    assert consecutive.valid?, consecutive.errors.full_messages.to_sentence
  end
end
