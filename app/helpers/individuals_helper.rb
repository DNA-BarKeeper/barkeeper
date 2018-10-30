module IndividualsHelper
  def habitat_for_display(individual)
    if individual.habitat.present? && (individual.habitat.length > 60)
      (individual.habitat[0..30]...individual.habitat[-30..-1]).to_s
    else
      individual.habitat
    end
  end

  def locality_for_display(individual)
    if individual.locality.present? && (individual.locality.length > 60)
      (individual.locality[0..30]...individual.locality[-30..-1]).to_s
    else
      individual.locality
    end
  end

  def comments_for_display(individual)
    if individual.comments.present? && (individual.comments.length > 60)
      (individual.comments[0..30]...individual.comments[-30..-1]).to_s
    else
      individual.comments
    end
  end
end
