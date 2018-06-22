module MislabelAnalysisHelper
  def percentage_mislabels(mislabel_analysis)
    "Percentage of mislabeled sequences in this analysis: #{mislabel_analysis.mislabels.size} / #{mislabel_analysis.marker_sequences.size} (#{mislabel_analysis.percentage_of_mislabels}%)"
  end

  def mislabels(sequence)
    html = ''

    sequence.mislabels.order(:solved).each do |mislabel|
      solved = ''
      solved_by = ''

      if mislabel.solved
        begin
          user = User.find(mislabel.solved_by).name
        rescue
          user = 'unknown user'
        end
        solved_by = "Solved by #{user} on #{mislabel.solved_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S")}"
      else
        solved = "<span class='glyphicon glyphicon-exclamation-sign' style='color: red'></span>".html_safe
        solved_by = link_to('Mark mislabel as solved', solve_mislabel_path(mislabel))
      end

      html << '<tr>'
      html << content_tag(:td, solved, style: 'text-align: center')
      html << content_tag(:td, mislabel.level)
      html << content_tag(:td, mislabel.proposed_label)
      html << content_tag(:td, mislabel.confidence)
      html << content_tag(:td, solved_by)
      html << '</tr>'
    end

    html.html_safe
  end

  def warnings_present(marker_sequences)
    has_warnings = false

    marker_sequences.each do |ms|
      has_warnings = ms.has_unsolved_mislabels
      break if has_warnings
    end

    has_warnings
  end

  def warning_color(marker_sequences)
    "color: #{warnings_present(marker_sequences) ? 'red' : 'grey'}"
  end

  def contigs_with_warnings(contigs)
    list_elements = []
    contigs.each do |c|
      list_elements << content_tag(:li, link_to(c.name, edit_contig_path(c))) if c.marker_sequence.has_unsolved_mislabels
    end

    html = ''
    if list_elements.blank?
      html << '<p>There are no SATIVA warnings associated with this record.</p>'
    else
      html << '<p>One or more contigs associated with this object contain warnings from a SATIVA analysis:</p>'
      html << '<ul>'
      list_elements.each { |li| html << li }
      html << '</ul>'
      html << '<p>Please visit the contig page(s) for more information.</p>'
    end

    html.html_safe
  end
end