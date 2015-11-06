require "spec_helper"

describe Lita::Handlers::Ambush, lita_handler: true do

  it "expect route exists" do
    is_expected.to route("ambush: user1: this is test plugin")
  end
  

  it "testing storage into redis" do
    user1 = Lita::User.create(123, name: "user1")
    send_message("ambush: user1: this is test plugin", as: user1)
    # require 'pry'; binding.pry
    expect(replies.last).to eq("#{user1.name} I've stored the ambush")
    redis_rpop= Lita.redis.rpop("handlers:ambush:#{user1.name}") ;
    expect(redis_rpop ).to eq("this is test plugin")
  end

  it "should send out two messages" do
    user1 = Lita::User.create(123, name: "user1")
    send_message("ambush: user1: this is test plugin data 1", as: user1)
    send_message("ambush: user1: this is test plugin data 2", as: user1)
    expect(replies.last).to eq("#{user1.name} I've stored the ambush")
    expect(replies.last).to eq("#{user1.name} I've stored the ambush")
    expect(Lita.redis.rpop("handlers:ambush:#{user1.name}") ).to eq("this is test plugin data 1")
    expect(Lita.redis.rpop("handlers:ambush:#{user1.name}") ).to eq("this is test plugin data 2")




  end

end
