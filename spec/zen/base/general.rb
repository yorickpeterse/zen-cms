require File.expand_path '../../spec', __FILE__

describe Zen::General do

  it 'Create a relative path from spec/zen to lib/zen' do
    start_dir = File.expand_path '../../', __FILE__
    end_dir   = File.expand_path '../../../../lib/zen', __FILE__
    
    # Generate the relative path
    path = Zen::General.relative_from_to start_dir, end_dir

    # Check if the path is correct
    path.should.equal '../../lib/zen'
  end

end