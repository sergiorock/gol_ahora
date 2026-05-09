class EntrenamientoPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def new?     = user&.admin?
  def create?  = user&.admin?
  def edit?    = user&.admin?
  def update?  = user&.admin?
  def destroy? = user&.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
