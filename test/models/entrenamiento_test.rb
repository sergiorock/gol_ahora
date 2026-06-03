require "test_helper"

class EntrenamientoTest < ActiveSupport::TestCase
  def entrenamiento_base_attrs(pd)
    {
      nombre: "Entrenamiento de prueba",
      scheduled_at: 1.day.from_now,
      duration_minutes: 90,
      max_students: 8,
      personal_deportivo: pd
    }
  end

  def entrenador_certificado
    pd = personal_deportivos(:entrenador_apto)
    pd.certificacion_archivo.attach(
      io: StringIO.new("cert"),
      filename: "cert.pdf",
      content_type: "application/pdf"
    )
    pd
  end

  # ─── Asignación válida ───────────────────────────────────────────────────────

  test "entrenamiento con entrenador certificado es válido" do
    ent = Entrenamiento.new(entrenamiento_base_attrs(entrenador_certificado))
    assert ent.valid?, ent.errors.full_messages.to_sentence
  end

  # ─── Asignación inválida: sin certificación ──────────────────────────────────

  test "entrenamiento con entrenador sin ninguna certificación es inválido" do
    pd = personal_deportivos(:entrenador_sin_certificacion)
    ent = Entrenamiento.new(entrenamiento_base_attrs(pd))
    assert_not ent.valid?
    assert_includes ent.errors[:personal_deportivo_id],
                    "no posee certificación válida registrada"
  end

  test "entrenamiento con entrenador con texto y fecha pero sin archivo es inválido" do
    pd = personal_deportivos(:entrenador_apto)
    ent = Entrenamiento.new(entrenamiento_base_attrs(pd))
    assert_not ent.valid?
    assert ent.errors[:personal_deportivo_id].any?
  end

  # ─── Validaciones propias de Entrenamiento ───────────────────────────────────

  test "no es válido sin nombre" do
    ent = Entrenamiento.new(entrenamiento_base_attrs(entrenador_certificado).merge(nombre: nil))
    assert_not ent.valid?
    assert ent.errors[:nombre].any?
  end

  test "duration_minutes debe ser mayor a 0" do
    ent = Entrenamiento.new(entrenamiento_base_attrs(entrenador_certificado).merge(duration_minutes: 0))
    assert_not ent.valid?
    assert ent.errors[:duration_minutes].any?
  end

  test "max_students debe ser mayor a 0" do
    ent = Entrenamiento.new(entrenamiento_base_attrs(entrenador_certificado).merge(max_students: 0))
    assert_not ent.valid?
    assert ent.errors[:max_students].any?
  end
end
