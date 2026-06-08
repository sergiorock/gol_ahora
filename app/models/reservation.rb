class Reservation < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :court
  has_many :payments, dependent: :destroy
  has_one :deposit_charge, -> { where(is_deposit: true) },  class_name: "Charge", dependent: :nullify
  has_one :balance_charge, -> { where(is_deposit: false) }, class_name: "Charge", dependent: :nullify

  DEPOSIT_RATIO = 0.30

  aasm column: :status do
    state :pending, initial: true
    state :confirmed
    state :in_progress
    state :finished
    state :cancelled

    event :confirm do
      transitions from: :pending, to: :confirmed
    end

    event :start do
      transitions from: :confirmed, to: :in_progress
    end

    event :finish do
      transitions from: %i[in_progress confirmed], to: :finished
    end

    event :cancel do
      transitions from: %i[pending confirmed], to: :cancelled
    end
  end

  validates :starts_at, :ends_at, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :deposit_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :ends_after_starts
  validate :within_max_duration
  validate :not_too_far_in_advance
  validate :no_overlap
  validate :not_blocked
  validate :confirmed_requires_deposit

  def duration_minutes
    ((ends_at - starts_at) / 60).to_i
  end

  def approved_deposit
    payments.where(payment_type: :deposit, status: :approved).first
  end

  def deposit_paid?
    deposit_charge.present? || approved_deposit.present? || payments.where(payment_type: :deposit, status: :approved).exists?
  end

  private

  def ends_after_starts
    return unless starts_at && ends_at
    errors.add(:ends_at, "debe ser posterior a la hora de inicio") if ends_at <= starts_at
  end

  def within_max_duration
    return unless starts_at && ends_at && court
    max = court.court_type.max_duration_minutes
    errors.add(:ends_at, "supera la duración máxima de #{max} minutos") if duration_minutes > max
  end

  def not_too_far_in_advance
    return unless starts_at
    errors.add(:starts_at, "no puede reservarse con más de 30 días de anticipación") if starts_at > 30.days.from_now
  end

  def no_overlap
    return unless starts_at && ends_at && court
    overlap = Reservation.where(court_id: court_id)
                         .where.not(status: %w[cancelled])
    overlap = overlap.where.not(id: id) if id.present?
    overlap = overlap.where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
    errors.add(:base, "la cancha ya está reservada en ese horario") if overlap.exists?
  end

  def not_blocked
    return unless starts_at && ends_at && court
    errors.add(:base, "la cancha está bloqueada en ese horario") if court.blocked_at?(starts_at, ends_at)
  end

  def confirmed_requires_deposit
    return unless status.to_s == "confirmed"
    if deposit_amount.to_d.zero?
      errors.add(:base, "no se puede confirmar la reserva presencial sin cobro registrado") unless balance_charge.present?
    else
      paid = deposit_charge.present? || approved_deposit.present? || payments.where(payment_type: :deposit, status: :approved).exists?
      errors.add(:base, "no se puede confirmar la reserva sin el pago de la seña") unless paid
    end
  end

end
