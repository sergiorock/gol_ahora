require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  def setup
    @user  = users(:member)
    @court = courts(:cancha_a)
    base   = 7.days.from_now.change(hour: 9, min: 0, sec: 0, usec: 0)
    @reservation = Reservation.create!(
      court: @court, user: @user,
      starts_at: base, ends_at: base + 1.hour,
      total_amount: 1000, deposit_amount: 300
    )
  end

  def valid_attrs
    {
      reservation: @reservation,
      payment_type: :deposit,
      status: :approved,
      amount: 300,
      last_four_digits: "1234",
      cardholder_name: "Ana García",
      expiry_date: "12/27"
    }
  end

  # ─── Validaciones ────────────────────────────────────────────────────────────

  test "válido con todos los campos correctos" do
    assert Payment.new(valid_attrs).valid?
  end

  test "amount debe ser mayor a 0" do
    p = Payment.new(valid_attrs.merge(amount: 0))
    assert_not p.valid?
    assert p.errors[:amount].any?
  end

  test "last_four_digits debe tener exactamente 4 dígitos numéricos" do
    ["123", "12345", "ABCD", "12 4"].each do |val|
      p = Payment.new(valid_attrs.merge(last_four_digits: val))
      assert_not p.valid?, "#{val.inspect} debería ser inválido"
      assert p.errors[:last_four_digits].any?
    end
  end

  test "last_four_digits con 4 dígitos es válido" do
    p = Payment.new(valid_attrs.merge(last_four_digits: "0000"))
    assert p.valid?, p.errors.full_messages.to_sentence
  end

  test "expiry_date debe tener formato MM/AA" do
    ["2027-12", "1/27", "13/27", "00/27", "12-27"].each do |val|
      p = Payment.new(valid_attrs.merge(expiry_date: val))
      assert_not p.valid?, "#{val.inspect} debería ser inválido"
      assert p.errors[:expiry_date].any?
    end
  end

  test "expiry_date acepta meses del 01 al 12" do
    %w[01/27 06/27 12/27].each do |date|
      p = Payment.new(valid_attrs.merge(expiry_date: date))
      assert p.valid?, "#{date} debería ser válido: #{p.errors.full_messages.to_sentence}"
    end
  end

  test "requiere cardholder_name" do
    p = Payment.new(valid_attrs.merge(cardholder_name: nil))
    assert_not p.valid?
    assert p.errors[:cardholder_name].any?
  end

  # ─── Callback: create_charge_for_deposit ─────────────────────────────────────

  test "approved deposit crea un Charge automáticamente" do
    assert_difference "Charge.count", 1 do
      Payment.create!(valid_attrs)
    end
  end

  test "approved deposit crea un Receipt automáticamente" do
    assert_difference "Receipt.count", 1 do
      Payment.create!(valid_attrs)
    end
  end

  test "el Charge creado por deposit tiene is_deposit: true" do
    Payment.create!(valid_attrs)
    charge = @reservation.reload.deposit_charge
    assert_not_nil charge
    assert charge.is_deposit
    assert_in_delta 300.0, charge.amount.to_f, 0.01
  end

  test "deposit rechazado no crea Charge" do
    assert_no_difference "Charge.count" do
      Payment.create!(valid_attrs.merge(status: :rejected))
    end
  end

  test "pago full aprobado no crea Charge via el callback de deposit" do
    assert_no_difference "Charge.count" do
      Payment.create!(valid_attrs.merge(payment_type: :full))
    end
  end
end
