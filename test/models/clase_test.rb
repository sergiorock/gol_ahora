require "test_helper"

class ClaseTest < ActiveSupport::TestCase
  def clase_base_attrs(pd)
    {
      nombre: "Clase de prueba",
      scheduled_at: 1.day.from_now,
      duration_minutes: 60,
      max_students: 10,
      personal_deportivo: pd
    }
  end

  def profesor_certificado
    pd = personal_deportivos(:profesor_apto)
    pd.certificacion_archivo.attach(
      io: StringIO.new("cert"),
      filename: "cert.pdf",
      content_type: "application/pdf"
    )
    pd
  end

  # ─── Asignación válida ───────────────────────────────────────────────────────

  test "clase con profesor certificado es válida" do
    clase = Clase.new(clase_base_attrs(profesor_certificado))
    assert clase.valid?, clase.errors.full_messages.to_sentence
  end

  # ─── Asignación inválida: sin certificación ──────────────────────────────────

  test "clase con profesor sin ninguna certificación es inválida" do
    pd = personal_deportivos(:profesor_sin_certificacion)
    clase = Clase.new(clase_base_attrs(pd))
    assert_not clase.valid?
    assert_includes clase.errors[:personal_deportivo_id],
                    "no posee certificación válida registrada"
  end

  test "clase con profesor que solo tiene texto de certificación es inválida" do
    pd = personal_deportivos(:profesor_solo_texto)
    clase = Clase.new(clase_base_attrs(pd))
    assert_not clase.valid?
    assert clase.errors[:personal_deportivo_id].any?
  end

  test "clase con profesor que solo tiene fecha (sin archivo) es inválida" do
    pd = personal_deportivos(:profesor_solo_fecha)
    clase = Clase.new(clase_base_attrs(pd))
    assert_not clase.valid?
    assert clase.errors[:personal_deportivo_id].any?
  end

  test "clase con texto y fecha pero sin archivo es inválida" do
    pd = personal_deportivos(:profesor_apto)
    clase = Clase.new(clase_base_attrs(pd))
    assert_not clase.valid?
    assert clase.errors[:personal_deportivo_id].any?
  end

  # ─── Validaciones propias de Clase ──────────────────────────────────────────

  test "no es válida sin nombre" do
    clase = Clase.new(clase_base_attrs(profesor_certificado).merge(nombre: nil))
    assert_not clase.valid?
    assert clase.errors[:nombre].any?
  end

  test "duration_minutes debe ser mayor a 0" do
    clase = Clase.new(clase_base_attrs(profesor_certificado).merge(duration_minutes: 0))
    assert_not clase.valid?
    assert clase.errors[:duration_minutes].any?
  end

  test "max_students debe ser mayor a 0" do
    clase = Clase.new(clase_base_attrs(profesor_certificado).merge(max_students: 0))
    assert_not clase.valid?
    assert clase.errors[:max_students].any?
  end
end
