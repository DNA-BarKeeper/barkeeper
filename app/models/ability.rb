# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    # Permissions for every user, even if not logged in
    can %i[about progress impressum privacy_policy], :home
    can :manage, :progress_overview

    can %i[edit index filter taxonomy_tree associated_specimen find_ancestry show_individuals], Taxon
    can %i[edit index filter], Individual
    can %i[edit index], Herbarium

    can %i[edit index filter change_via_script compare_contigs as_fasq], Contig
    can %i[edit index filter], Isolate
    can [:filter], MarkerSequence
    can :manage, PartialCon
    can %i[edit index], PrimerRead
    can :manage, TxtUploader
    can :download_results, MislabelAnalysis
    can [:import, :revised_tpm], NgsRun

    # Additional permissions for logged in users
    if user.present?
      can :manage, :all

      # Additional permissions for guests
      if user.guest?
        cannot %i[change_base change_left_clip change_right_clip], PrimerRead
        cannot %i[create update destroy], :all
        can :edit, :all
      end

      cannot :manage, User
      cannot :manage, Project
      cannot :manage, Responsibility
      cannot %i[create destroy], MislabelAnalysis
      cannot %i[create destroy], Mislabel
      cannot :start_analysis, NgsRun # TODO: remove when feature is done

      can %i[read search_taxa add_to_taxa], Project, id: user.project_ids

      cannot :edit, Cluster

      # Additional permissions for administrators and supervisors
      if user.admin? || user.supervisor?
        can :manage, User
        can :manage, Project
        can :manage, Responsibility
        can :manage, MislabelAnalysis
        can :manage, Mislabel
        can :manage, Cluster
        can :manage, NgsRun

        cannot %i[create update destroy], User, role: 'admin' if user.supervisor?
      end

      can %i[home show edit update destroy], User, id: user.id # User can see and edit own profile

      cannot :manage, ContigSearch
      can :create, ContigSearch
      can :manage, ContigSearch, user_id: user.id # Users can only edit their own searches

      cannot :manage, MarkerSequenceSearch
      can :create, MarkerSequenceSearch
      can :manage, MarkerSequenceSearch, user_id: user.id # Users can only edit their own searches

      cannot :manage, IndividualSearch
      can :create, IndividualSearch
      can :manage, IndividualSearch, user_id: user.id # Users can only edit their own searches

      if user.responsibilities.exists?(name: 'lab') # Restrictions for users in project "lab"
        cannot %i[create update destroy], [Taxon, Individual]
        can :edit, [Taxon, Individual]
      elsif user.responsibilities.exists?(name: 'taxonomy') # Restrictions for users in project "taxonomy"
        cannot %i[create update destroy], [Alignment, Contig, Freezer, Isolate, Issue, Lab, LabRack, Marker,
                                           MarkerSequence, MicronicPlate, PartialCon, PlantPlate, Primer, PrimerRead, Shelf, Tissue]
        can :edit, [Alignment, Contig, Freezer, Isolate, Issue, Lab, LabRack, Marker, MarkerSequence, MicronicPlate,
                    PartialCon, PlantPlate, Primer, PrimerRead, Shelf, Tissue]
        cannot %i[change_base change_left_clip change_right_clip], PrimerRead
      end

      cannot :delete_all, ContigSearch unless user.responsibilities.exists?(name: 'delete_contigs') || user.admin? || user.supervisor?
    end
  end
end
