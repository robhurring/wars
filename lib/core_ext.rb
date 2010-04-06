class Range
  def rand
    min + Kernel.rand(max+1 - min) 
  end
end