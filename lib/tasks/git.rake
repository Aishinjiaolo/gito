# -*- encoding : utf-8 -*-
namespace :git do
  git       = "git-1.8.4"
  cwd       = Rake.application.original_dir
  git_dir   = "#{cwd}/vendor/#{git}"
  build_dir = "#{cwd}/vendor/#{git}/build"

  desc "Build Git"
  task :build do
    command = "cd #{git_dir}; make -i prefix=#{build_dir} NO_TCLTK=true; make install -i prefix=#{build_dir} NO_TCLTK=true"
    puts "Let't build #{git}"
    puts command
    sh "$command"
    puts "#{git} build is done"
  end
end
