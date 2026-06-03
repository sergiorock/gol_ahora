require "test_helper"

class ChargeTest < ActiveSupport::TestCase
  def setup
    @user = users(:member)
  end

  def charge_attrs(overrides = {})
    {
      user: @user, amount: 1000, concept: "Cobro test",
      charge_type: :rental, payment_method: :cash, date: Date.today
    }.merge(overrides)
  end

  # ─── Validaciones ────────────────────────────────────────────────────────────

  test "válido con todos los campos correctos" do
    assert Charge.new(charge_attrs).valid?
  end

  test "amount debe ser mayor a 0" do
    c = Charge.new(charge_attrs(amount: 0))
    assert_not c.valid?
    assert c.errors[:amount].any?
  end

  test "requiere concept" do
    c = Charge.new(charge_attrs(concept: nil))
    assert_not c.valid?
    assert c.errors[:concept].any?
  end

  test "requiere charge_type" do
    c = Charge.new(charge_attrs(charge_type: nil))
    assert_not c.valid?
    assert c.errors[:charge_type].any?
  end

  test "requiere payment_method" do
    c = Charge.new(charge_attrs(payment_method: nil))
    assert_not c.valid?
    assert c.errors[:payment_method].any?
  end

  test "requiere date" do
    c = Charge.new(charge_attrs(date: nil))
    assert_not c.valid?
    assert c.errors[:date].any?
  end

  # ─── apply_discount ──────────────────────────────────────────────────────────

  test "descuento porcentual reduce el monto correctamente" do
    discount = Discount.create!(name: "10% off", discount_type: :percentage, value: 10, active: true)
    c = Charge.create!(charge_attrs(amount: 1000, discount: discount))
    assert_in_delta 900.0, c.amount.to_f, 0.01
  end

  test "descuento fijo reduce el monto correctamente" do
    discount = Discount.create!(name: "$200 off", discount_type: :fixed, value: 200, active: true)
    c = Charge.create!(charge_attrs(amount: 1000, discount: discount))
    assert_in_delta 800.0, c.amount.to_f, 0.01
  end

  test "descuento inactivo no modifica el monto" do
    discount = Discount.create!(name: "Inactivo", discount_type: :percentage, value: 50, active: false)
    c = Charge.create!(charge_attrs(amount: 1000, discount: discount))
    assert_in_delta 1000.0, c.amount.to_f, 0.01
  end

  test "descuento fijo no produce monto negativo" do
    discount = Discount.create!(name: "Descuento enorme", discount_type: :fixed, value: 9999, active: true)
    c = Charge.create!(charge_attrs(amount: 100, discount: discount))
    assert_in_delta 0.0, c.amount.to_f, 0.01
  end

  # ─── finalize_reservation_if_balance ─────────────────────────────────────────

  test "balance charge sobre reserva confirmada la finaliza" do
    court = courts(:cancha_a)
    base  = 5.days.from_now.change(hour: 10, min: 0, sec: 0, usec: 0)
    res   = Reservation.create!(
      court: court, user: @user,
      starts_at: base, ends_at: base + 1.hour,
      total_amount: 1000, deposit_amount: 300
    )
    res.update_column(:status, "confirmed")

    Charge.create!(charge_attrs(
      reservation: res, amount: 700,
      concept: "Saldo reserva", is_deposit: false
    ))

    assert res.reload.finished?
  end

  test "deposit charge no finaliza la reserva" do
    court = courts(:cancha_a)
    base  = 6.days.from_now.change(hour: 10, min: 0, sec: 0, usec: 0)
    res   = Reservation.create!(
      court: court, user: @user,
      starts_at: base, ends_at: base + 1.hour,
      total_amount: 1000, deposit_amount: 300
    )

    Charge.create!(charge_attrs(
      reservation: res, amount: 300,
      concept: "Seña", is_deposit: true
    ))

    assert res.reload.pending?
  end
end
