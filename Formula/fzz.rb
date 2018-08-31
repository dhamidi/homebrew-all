class Fzz < Formula
  desc 'fzz allows you to change the input of a single command interactively'
  homepage 'https://github.com/mrnugget/fzz'
  url 'https://github.com/mrnugget/fzz/archive/v1.1.0.tar.gz'
  sha256 '2358f905de977ce07b596cfc99d7e6c42fabe6e7fa2e10de4c77766c91051ffd'

  depends_on 'go' => :build

  def install
    ENV['GOPATH'] = buildpath
    (buildpath/'src/github.com/mrnugget/fzz').install buildpath.children

    cd 'src/github.com/mrnugget/fzz' do
      system 'go', 'get', '.'
      system 'go', 'build', '-o', bin / 'fzz'
      man1.install 'man/fzz.1'
    end
  end

  def test
    assert File.exist?(bin / 'fzz')
  end
end
