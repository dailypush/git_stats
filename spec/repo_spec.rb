require 'spec_helper'

describe GitStats::GitData::Repo do
  let(:repo) { build(:repo) }
  let(:expected_authors) { {
      "john.doe@gmail.com" => build(:author, repo: repo, name: "John Doe", email: "john.doe@gmail.com"),
      "joe.doe@gmail.com" => build(:author, repo: repo, name: "Joe Doe", email: "joe.doe@gmail.com")
  } }

  describe 'git output parsing' do
    it 'should parse git shortlog output to authors hash' do
      GitStats::GitData::Command.any_instance.should_receive(:run_in_repo).and_return("   156	John Doe <john.doe@gmail.com>
    53	Joe Doe <joe.doe@gmail.com>
")

      repo.authors.should == expected_authors
    end

    it 'should parse git revlist output to date sorted commits array' do
      GitStats::GitData::Command.any_instance.should_receive(:run_in_repo).and_return("e4412c3|1348603824|2012-09-25 22:10:24 +0200|john.doe@gmail.com
ce34874|1347482927|2012-09-12 22:48:47 +0200|joe.doe@gmail.com
5eab339|1345835073|2012-08-24 21:04:33 +0200|john.doe@gmail.com
")

      repo.stub(authors: expected_authors)

      repo.commits.should == [
          GitStats::GitData::Commit.new(
              repo: repo, hash: "5eab339", stamp: "1345835073", date: DateTime.parse("2012-08-24 21:04:33 +0200"),
              author: repo.authors["john.doe@gmail.com"]),
          GitStats::GitData::Commit.new(
              repo: repo, hash: "ce34874", stamp: "1347482927", date: DateTime.parse("2012-09-12 22:48:47 +0200"),
              author: repo.authors["joe.doe@gmail.com"]),
          GitStats::GitData::Commit.new(
              repo: repo, hash: "e4412c3", stamp: "1348603824", date: DateTime.parse("2012-09-25 22:10:24 +0200"),
              author: repo.authors["john.doe@gmail.com"])
      ]
    end
  end
end