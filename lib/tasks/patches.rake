desc "Send patch information to the foreman-dev list"
task :mail_patches do
    if Dir.glob("00*.patch").length > 0
        raise "Patches already exist matching '00*.patch'; clean up first"
    end

    # Create all of the patches
    sh "git format-patch -C -M -s -n --subject-prefix='PATCH/foreman' origin/0.4-stable"

    # If we've got more than one patch, add --compose
    compose = Dir.glob("00*.patch").length > 1 ? "--compose" : ""

    # Now send the mail.
    sh "git send-email #{compose} --no-signed-off-by-cc --suppress-from --to foreman-dev@googlegroups.com 00*.patch"

    # Finally, clean up the patches
    sh "rm 00*.patch"
end

