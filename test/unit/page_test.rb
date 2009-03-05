require 'test_helper'

class PageTest < ActiveSupport::TestCase
  
  def setup
    @user1 = User.create :login => 'demo', :email => "f@b.com", :password => 'foobar', :password_confirmation => 'foobar'
    @user2 = User.create :login => 'show', :email => "f@b.com", :password => 'foobar', :password_confirmation => 'foobar'
  end
  
  def test_aggregation
    # Create two nodes and move them beneath the root node
    n1 = Node.create! :slug => "one"
    n2 = Node.create! :slug => "two"
    n1.move_to_child_of Node.root
    n2.move_to_child_of Node.root
    
    # get the drafts and assign a user to it
    assert_not_nil d1 = n1.find_or_create_draft( @user1 )
    assert_not_nil d3 = n2.find_or_create_draft( @user1 )
    
    # tag and double publish so we have 4 pages tagged with "update"
    d1.tag_list = "update"
    d1.save
    n1.publish_draft!

    d2 = n1.find_or_create_draft @user1
    n1.publish_draft!
    
    
    d3.tag_list = "update, pressemitteilung"
    d3.save
    n2.publish_draft!

    d4 = n2.find_or_create_draft @user1
    n2.publish_draft!
    
    # Set up two options hashes for the assertions
    options1 = {
      :tags => "update"
    }
    
    options2 = {
      :tags => "update, pressemitteilung"
    }
    
    assert_equal 2, Page.aggregate( options1 ).length
    assert_equal 1, Page.aggregate( options2 ).length
    assert_equal 4, Page.find_tagged_with( "update" ).count
    assert_equal [d2.id, d4.id], Page.aggregate( options1 ).map {|x| x.id}
  end
  
  def test_before_save_rewrite_links_in_body
    n = Node.create :slug => "link_test"
    n.move_to_child_of Node.root
    d = n.find_or_create_draft @user1
    
    before = "<h1>Hello World</h1>\n" \
             "<a href=\"/club\" target=\"_blank\">Linkme</a>"
    
    after  = "<h1>Hello World</h1>\n" \
             "<a href=\"/de/club\" target=\"_blank\">Linkme</a>"
    
    I18n.locale = :de
    
    d.body = before
    d.save
    
    assert_equal after, d.body
  end
  
  def test_before_save_rewrite_links_in_body_if_no_locale_prefix_present
    n = Node.create :slug => "link_test"
    n.move_to_child_of Node.root
    d = n.find_or_create_draft @user1
    
    before = "<h1>Hello World</h1>\n" \
             "<a href=\"/de/club\" target=\"_blank\">Linkme</a>"
    
    after  = "<h1>Hello World</h1>\n" \
             "<a href=\"/de/club\" target=\"_blank\">Linkme</a>"
    
    I18n.locale = :de
    
    d.body = before
    d.save
    
    assert_equal after, d.body
  end
  
  def test_before_save_rewrite_links_skips_on_external_links
    n = Node.create :slug => "link_test"
    n.move_to_child_of Node.root
    d = n.find_or_create_draft @user1
    
    before = "<h1>Hello World</h1>\n" \
             "<a href=\"http://www.ccc.de/club\" target=\"_blank\">Linkme</a>"
    
    after  = "<h1>Hello World</h1>\n" \
             "<a href=\"http://www.ccc.de/club\" target=\"_blank\">Linkme</a>"
    
    I18n.locale = :de
    
    d.body = before
    d.save
    
    assert_equal after, d.body
  end
end
