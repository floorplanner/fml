def transform_with(class_prefix,&block)
  transforms = []
  ObjectSpace.each_object(Class) do |k|
    next if !k.to_s.include?(class_prefix) || transforms.include?(k)
    transforms << k
  end
  transforms.each {|t| block.call(t)}
end
