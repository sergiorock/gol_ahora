class PaymentPolicy < ApplicationPolicy
  def create? = user.present? && record.reservation.user_id == user.id
  def show?   = user&.admin? || record.reservation.user_id == user&.id
end
