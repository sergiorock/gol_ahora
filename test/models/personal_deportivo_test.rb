require "test_helper"

class PersonalDeportivoTest < ActiveSupport::TestCase
  def attach_cert(pd)
    pd.certificacion_archivo.attach(
      io: StringIO.new("contenido de prueba"),
      filename: "certificado.pdf",
      content_type: "application/pdf"
    )
  end

  # ─── certificacion_valida? ───────────────────────────────────────────────────

  test "sin ningún campo de certificación retorna false" do
    assert_not personal_deportivos(:profesor_sin_certificacion).certificacion_valida?
  end

  test "con solo texto retorna false" do
    assert_not personal_deportivos(:profesor_solo_texto).certificacion_valida?
  end

  test "con solo fecha retorna false" do
    assert_not personal_deportivos(:profesor_solo_fecha).certificacion_valida?
  end

  test "con texto y fecha pero sin archivo retorna false" do
    assert_not personal_deportivos(:profesor_apto).certificacion_valida?
  end

  test "profesor con los tres campos presentes retorna true" do
    pd = personal_deportivos(:profesor_apto)
    attach_cert(pd)
    assert pd.certificacion_valida?
  end

  test "entrenador con los tres campos presentes retorna true" do
    pd = personal_deportivos(:entrenador_apto)
    attach_cert(pd)
    assert pd.certificacion_valida?
  end

  test "entrenador sin certificación retorna false" do
    assert_not personal_deportivos(:entrenador_sin_certificacion).certificacion_valida?
  end

  # ─── Validaciones de estructura ──────────────────────────────────────────────

  test "no es válido sin nombre" do
    pd = PersonalDeportivo.new(apellido: "García", tipo: :profesor)
    assert_not pd.valid?
    assert pd.errors[:nombre].any?
  end

  test "no es válido sin apellido" do
    pd = PersonalDeportivo.new(nombre: "Ana", tipo: :profesor)
    assert_not pd.valid?
    assert pd.errors[:apellido].any?
  end

  test "no es válido sin tipo" do
    pd = PersonalDeportivo.new(nombre: "Ana", apellido: "García")
    assert_not pd.valid?
    assert pd.errors[:tipo].any?
  end

  test "fecha_certificacion no puede ser futura" do
    pd = PersonalDeportivo.new(nombre: "Ana", apellido: "García", tipo: :profesor,
                               fecha_certificacion: Date.today + 1)
    assert_not pd.valid?
    assert pd.errors[:fecha_certificacion].any?
  end

  test "si hay fecha, el archivo es obligatorio" do
    pd = PersonalDeportivo.new(nombre: "Ana", apellido: "García", tipo: :profesor,
                               certificacion_deportiva: "Prof. Tenis",
                               fecha_certificacion: Date.today)
    assert_not pd.valid?
    assert pd.errors[:certificacion_archivo].any?
  end
end
