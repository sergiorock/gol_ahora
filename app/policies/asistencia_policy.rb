class AsistenciaPolicy < ApplicationPolicy
  def index?   = user&.admin?
  def create?  = user.present?
  def update?  = user&.admin?
  def destroy? = user&.admin? || record.user_id == user&.id

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
