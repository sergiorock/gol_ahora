class EnrollmentPolicy < ApplicationPolicy
  def index?   = true
  def show?    = user&.admin? || record.user_id == user&.id
  def create?  = user.present?
  def update?  = user&.admin?
  def destroy? = user&.admin? || record.user_id == user&.id

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(user: user)
    end
  end
end
