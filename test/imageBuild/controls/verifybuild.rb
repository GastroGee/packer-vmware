title "Verify Base Application Binary"

control 'audit installation checks' do
    impact 1.0
    title 'os and packages'
    desc 'verify os type and packages installed'

    installs = ["wget","uzip","git", "jq", "curl", "net-tools"]
    installs.each do |binaries|
        describe package(binaries) do
            it { should be_installed }
        end
    end
end

control 'check hashicorp binaries are installed' do
    impact 1.0 
    title 'hashicorp binaries'
    desc 'verify hashicorp binaries'

    dirs = ["/usr/local/bin/consul","/usr/local/bin/consul-template","/usr/local/bin/vault"]
    dirs.each do |path|
        describe file(path) do
            it { should exist}
        end
    end
end

control 'validate consul version' do
    impact 1.0
    title 'consul binary exists'
    desc 'verify consul version installed'
    describe command('consul version') do
        its('stdout') {should match /consul v1.10.2/}
    end
end

control 'validate consul-template version' do
    impact 1.0
    title 'consul-template binary exists'
    desc 'verify consul template version installed'
    describe command('consul-template -version') do
        its('stdout') {should match /v0.27.0/}
    end
end

control 'validate vault version' do
    impact 1.0
    title 'vault binary exists'
    desc 'verify vault version installed'
    describe command('vault version') do
        its('stdout') {should match /v1.8.2/}
    end
end