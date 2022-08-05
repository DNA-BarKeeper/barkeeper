#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    # Permissions for every user, even if not logged in
    can %i[about progress documentation impressum privacy_policy multisearch_app], :home
    can :manage, :progress_overview

    can %i[edit index filter taxonomy_tree associated_specimen find_ancestry show_individuals show_children], Taxon
    can %i[edit index filter locality], Individual
    can %i[edit index], Collection

    can %i[edit index filter change_via_script as_fasq], Contig
    can %i[edit index filter show_clusters], Isolate
    can [:filter], MarkerSequence
    can :manage, PartialCon
    can %i[edit index], PrimerRead
    can :download_results, MislabelAnalysis
    can [:import, :revised_tpm], NgsRun

    # Additional permissions for logged in users
    return unless user.present?
    can :manage, :all

    # Additional permissions for guests
    if user.guest?
      cannot %i[change_base change_left_clip change_right_clip], PrimerRead
      cannot %i[verify verify_next], Contig
      cannot %i[create update destroy], :all
      can :edit, :all
    end

    cannot %i[create update destroy], Project
    can :edit, Project

    cannot :manage, User
    cannot %i[create destroy], MislabelAnalysis
    cannot %i[create destroy], Mislabel
    cannot :start_analysis, NgsRun # TODO: remove when feature is done
    cannot :edit, Cluster

    # Additional permissions for administrators and supervisors
    if user.admin? || user.supervisor?
      can :manage, User
      can :manage, Project
      can :manage, MislabelAnalysis
      can :manage, Mislabel
      can :manage, Cluster
      can :manage, NgsRun
      can :update, Home # No user can add or destroy Home object, it's only created via seeding

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

    if user.lab? # Restrictions for users with responsibility "lab"
      cannot %i[create update destroy], [Taxon, Individual]
      can :edit, [Taxon, Individual]
    elsif user.taxonomy? # Restrictions for users with responsibility "taxonomy"
      cannot %i[create update destroy], [Contig, Freezer, Isolate, Issue, Lab, LabRack, Marker,
                                         MarkerSequence, MicronicPlate, PartialCon, PlantPlate, Primer, PrimerRead, Shelf, Tissue]
      can :edit, [Contig, Freezer, Isolate, Issue, Lab, LabRack, Marker, MarkerSequence, MicronicPlate,
                  PartialCon, PlantPlate, Primer, PrimerRead, Shelf, Tissue]
      cannot %i[change_base change_left_clip change_right_clip], PrimerRead
      cannot %i[verify verify_next], Contig
    end

    cannot :delete_all, ContigSearch unless user.bulk_delete_contigs? || user.admin? || user.supervisor?
  end
end
