# frozen_string_literal: true

module MislabelAnalysesHelper
  def percentage_mislabels(mislabel_analysis)
    percentage = mislabel_analysis.percentage_of_mislabels

    if percentage
      "Percentage of mislabeled sequences in this analysis: #{mislabel_analysis.mislabels.size} / #{mislabel_analysis.total_seq_number} (#{mislabel_analysis.percentage_of_mislabels}%)"
    else
      "#{mislabel_analysis.mislabels.size} potentially mislabeled sequences were identified in this analysis"
    end
  end

  def mislabels(sequence)
    html = +''.html_safe

    if sequence
      sequence.mislabels.includes(:mislabel_analysis).order(:solved).each do |mislabel|
        if mislabel.solved
          begin
            user = User.find(mislabel.solved_by).name
          rescue ActiveRecord::RecordNotFound
            user = 'unknown user'
          end
          solved_by = "Solved by #{user} on #{mislabel.solved_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S')}"
        else
          solved = content_tag(:span, '', class: %w(glyphicon glyphicon-exclamation-sign), style: 'color: red;')
          solved_by = link_to('Mark issue as solved', solve_mislabel_path(mislabel))
        end

        solved ||= ''

        html << content_tag(:tr) do
          content_tag(:td, solved, style: 'text-align: center') +
          content_tag(:td, mislabel.level) +
          content_tag(:td, mislabel.proposed_label) +
          content_tag(:td, mislabel.confidence) +
          content_tag(:td, mislabel.proposed_path) +
          content_tag(:td, mislabel.path_confidence) +
          content_tag(:td, (link_to mislabel.mislabel_analysis.title, mislabel_analysis_path(mislabel.mislabel_analysis))) +
          content_tag(:td, solved_by)
        end
      end
    end

    html
  end

  def warnings_present(marker_sequences)
    has_warnings = false

    if marker_sequences.size.positive?
      marker_sequences.each do |ms|
        has_warnings = ms&.has_unsolved_mislabels
        break if has_warnings
      end
    end

    has_warnings
  end

  def warning_color(marker_sequences)
    "color: #{warnings_present(marker_sequences) ? 'red' : 'grey'}"
  end

  def warning_color_individual(individual)
    "color: #{individual.has_issue ? 'red' : 'grey'}"
  end

  def contig_issues(contigs)
    list_elements = []

    if contigs.any? { |c| !c.nil? }
      contigs.each do |c|
        list_elements << content_tag(:li, link_to(c.name, edit_contig_path(c))) if c.marker_sequence&.has_unsolved_mislabels
      end
    end

    html = +''.html_safe
    if list_elements.blank?
      html << content_tag(:p, 'There are no SATIVA warnings associated with this record.')
    else
      html << content_tag(:p, 'One or more contigs associated with this object contain warnings from a SATIVA analysis:')
      html << content_tag(:ul) do
        list_elements.join.html_safe
      end
      html << content_tag(:p, "Please visit the contig #{'page'.pluralize(list_elements.size)} for more information.")
    end

    html
  end

  def contig_issues_individual(individual)
    contigs = Contig.joins(isolate: :individual).distinct.unsolved_warnings.where('individuals.id = ?', individual.id)

    list_elements = []
    contigs.includes(:marker_sequence).each do |c|
      list_elements << content_tag(:li, link_to(c.name, edit_contig_path(c))) if c.marker_sequence&.has_unsolved_mislabels
    end

    html = +''.html_safe
    if list_elements.blank?
      html << content_tag(:p, 'No issues are present for this record.')
    else
      html << content_tag(:p, 'Multiple contigs associated with this object contain warnings from a SATIVA analysis:')
      html << content_tag(:ul) do
        list_elements.join.html_safe
      end
      html << content_tag(:p, "Please visit the contig #{'page'.pluralize(list_elements.size)} for more information.")
    end

    html
  end
end
