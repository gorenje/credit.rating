class NilClass
  def empty?
    true
  end
end

class Array
  def average
    return nil if count == 0
    inject(&:+) / count.to_f
  end
end
