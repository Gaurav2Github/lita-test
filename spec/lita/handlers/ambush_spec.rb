require "spec_helper"
require 'yaml'

describe Lita::Handlers::Ambush, lita_handler: true do

  it "expect route exists" do
    is_expected.to route("ambush: user1: this is test plugin")
  end
  

  it "testing storage into redis" do
    user1 = Lita::User.create(123, name: "user1")
    send_command("ambush: user1: this is test plugin", as: user1)
    # require 'pry'; binding.pry
    expect(replies.last).to eq("#{user1.name} I've stored the ambush")
    redis_rpop= Lita.redis.rpop("handlers:ambush:#{user1.name}") ;
    outputed_yaml = YAML.load(redis_rpop)
    expect(outputed_yaml[:time] ).to be >0
    expect(outputed_yaml[:msg] ).to eq("this is test plugin")
  end

  it "should send out two messages" do
    user1 = Lita::User.create(123, name: "user1")
    send_command("ambush: user1: this is test plugin data 1", as: user1)
    send_command("ambush: user1: this is test plugin data 2", as: user1)
    expect(replies.last).to eq("#{user1.name} I've stored the ambush")
    expect(replies.last).to eq("#{user1.name} I've stored the ambush")
    redis_rpop1 = Lita.redis.rpop("handlers:ambush:#{user1.name}")
    redis_yaml1 = YAML.load(redis_rpop1)
    expect( redis_yaml1[:msg]).to eq("this is test plugin data 1")
    redis_rpop2 = Lita.redis.rpop("handlers:ambush:#{user1.name}")
    redis_yaml2 = YAML.load(redis_rpop2)
    expect( redis_yaml2[:msg]).to eq("this is test plugin data 2")

  end

  it { is_expected.to route("...............") }
  it { is_expected.to route("I am making good stuff") }
  it { is_expected.to route("This is remarkable") }
  it { is_expected.to route("Don't judge the book by its front cover") }

  it "should respond with the message stored" do
    user1 = Lita::User.create(123, name: "user1")
    user2 = Lita::User.create(453, name: "user2")
    send_command("ambush: #{user2.name}: this is a taco!", as: user1)
    send_message("I like to watch a nice sci-fi movie", as: user2)
    expect(replies.last).to eq("#{user2.name}: While you were out, #{user1.name} said: this is a taco!")
  end

  it "should do nothing with no messages" do
    user1 = Lita::User.create(123, name: "user1")
    user2 = Lita::User.create(453, name: "user2")
    send_message("I like to watch a nice sci-fi movie", as: user2)
    expect(replies.last).not_to eq("#{user2.name}: While you were out, #{user1.name} said: this is a taco!")
  end

  it "should respond with multiple messages stored" do
    user1 = Lita::User.create(123, name: "user1")
    user2 = Lita::User.create(453, name: "user2")
    send_command("ambush: user2: this is test plugin data 1", as: user1)
    send_command("ambush: user2: this is test plugin data 2", as: user1)
    send_message("I like to watch a nice sci-fi movie", as: user2)
    expect(replies[2]).to eq("#{user2.name}: While you were out, #{user1.name} said: this is test plugin data 1")
    expect(replies[3]).to eq("#{user2.name}: While you were out, #{user1.name} said: this is test plugin data 2")

  end
  
  

end
