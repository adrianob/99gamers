class PlanPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def sort?
    done_by_owner_or_admin?
  end

  def destroy?
    #done_by_owner_or_admin? && !record.any_sold?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    record.attribute_names.map(&:to_sym)
  end

  protected

  def done_by_owner_or_admin?
    user.present? && record.project.user == user || user.try(:admin?)
  end
end

