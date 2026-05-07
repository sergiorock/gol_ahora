class ReservationPolicy < ApplicationPolicy
  def index?   = true
  def show?    = admin? || owner?
  def new?     = user.present?
  def create?  = user.present?
  def update?  = admin?
  def edit?    = admin?
  def cancel?  = admin? || owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.all : scope.where(user: user)
    end
  end

  private

  def admin? = user&.admin?
  def owner? = record.user_id == user&.id
end
