require "test_helper"

class ReceiptTest < ActiveSupport::TestCase
  def setup
    @user = users(:member)
    @charge = Charge.create!(
      user: @user, amount: 500, concept: "Cobro para recibo",
      charge_type: :rental, payment_method: :cash, date: Date.today
    )
  end

  # ─── Generación automática de receipt_number ─────────────────────────────────

  test "genera receipt_number con formato REC-XXXXXX" do
    receipt = @charge.create_receipt!(concept: "Test")
    assert_match(/\AREC-\d{6}\z/, receipt.receipt_number)
  end

  test "asigna issued_at automáticamente" do
    receipt = @charge.create_receipt!(concept: "Test")
    assert_not_nil receipt.issued_at
  end

  test "el callback no genera número en update, permitiendo testear unicidad" do
    r1 = @charge.create_receipt!(concept: "Primero")
    charge2 = Charge.create!(
      user: @user, amount: 200, concept: "Segundo cobro",
      charge_type: :other, payment_method: :transfer, date: Date.today
    )
    r2 = charge2.create_receipt!(concept: "Segundo")
    assert_not_equal r1.receipt_number, r2.receipt_number

    # En update el before_validation :on => :create no corre,
    # así que podemos forzar el número duplicado para verificar la validación
    r2.receipt_number = r1.receipt_number
    assert_not r2.valid?
    assert r2.errors[:receipt_number].any?
  end

  # ─── Unicidad de receipt_number ──────────────────────────────────────────────

  test "modelo rechaza receipt_number duplicado al actualizar" do
    r1 = @charge.create_receipt!(concept: "Primero")
    charge2 = Charge.create!(
      user: @user, amount: 200, concept: "Segundo cobro",
      charge_type: :other, payment_method: :transfer, date: Date.today
    )
    r2 = charge2.create_receipt!(concept: "Segundo")

    r2.receipt_number = r1.receipt_number
    assert_not r2.valid?
    assert r2.errors[:receipt_number].any?
  end

  test "dos recibos de distintos cobros tienen receipt_numbers diferentes" do
    charge2 = Charge.create!(
      user: @user, amount: 100, concept: "Otro cobro",
      charge_type: :other, payment_method: :cash, date: Date.today
    )
    r1 = @charge.create_receipt!(concept: "Recibo 1")
    r2 = charge2.create_receipt!(concept: "Recibo 2")
    assert_not_equal r1.receipt_number, r2.receipt_number
  end

  test "concept se hereda del charge si no se especifica" do
    receipt = Receipt.new(charge: @charge, issued_at: Time.current)
    receipt.valid?
    assert_equal @charge.concept, receipt.concept
  end
end
