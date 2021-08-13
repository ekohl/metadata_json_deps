require 'spec_helper'
require 'json'
require 'tempfile'

describe MetadataJsonDeps do
  context 'no filenames' do
    subject { described_class.run([]) }

    it { expect { subject }.to_not output.to_stdout }
    it { expect { subject }.to_not output.to_stderr }
  end

  context 'with a module' do
    subject do
      Tempfile.create(['puppet-module', '.json']) do |f|
        mod = {
          "name": "puppet-dummy",
          "author": "Nobody",
          "license": "none",
          "source": "/dev/null",
          "summary": "Dummy",
          "version": "0.0.1",
          "dependencies": [
            {
              "name": module_name,
              "version_requirement": module_version,
            },
          ],
        }
        f.write(mod.to_json)
        f.flush

        described_class.run([f.path])
      end
    end

    let(:module_version) { '>= 0' }

    context 'that depends on a deprecated module' do
      context 'with replacement' do
        let(:module_name) { 'puppetlabs/mssql' }

        it { expect { subject }.to output(%r{\AChecking .+puppet-module.+\.json\n  puppetlabs/mssql was superseded by puppetlabs-sqlserver\Z}).to_stdout }
        it { expect { subject }.to_not output.to_stderr }
      end

      context 'without replacement' do
        context 'with reason' do
          let(:module_name) { 'puppetlabs/dsc' }

          it { expect { subject }.to output(%r{\AChecking .+puppet-module.+\.json\n  puppetlabs/dsc was deprecated: Migrate to https://forge\.puppet\.com/dsc modules\Z}).to_stdout }
          it { expect { subject }.to_not output.to_stderr }
        end

        # TODO find a module without a reason
        #context 'without reason' do
        #end
      end
    end

    context 'with current dependencies' do
      let(:module_name) { 'puppetlabs/stdlib' }

      it { expect { subject }.to output(%r{\AChecking .+puppet-module.+json\Z}).to_stdout }
      it { expect { subject }.to_not output.to_stderr }
    end

    context 'with an outdated dependency' do
      let(:module_name) { 'theforeman/motd' }
      let(:module_version) { '< 0.1.0' }

      it { expect { subject }.to output(%r{\AChecking .+puppet-module.+json\n  theforeman/motd \(< 0\.1\.0\) doesn't match 0\.1\.0\Z}).to_stdout }
      it { expect { subject }.to_not output.to_stderr }
    end
  end
end
