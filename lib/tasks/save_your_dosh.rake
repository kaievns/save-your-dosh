
namespace :save do
  namespace :your do
    desc "Runs the SaveYourDosh.mangle!"
    task :dosh do
      SaveYourDosh.mangle!
    end
  end
end