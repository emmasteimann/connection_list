class Debug
  @@mode = false

  class << self
    def mode
      @@mode
    end
    def set_mode(value)
      @@mode = value
    end
  end
end

class PersonId
  @@current_person_id = 0
  class << self
    def get_new_id
      @@current_person_id = @@current_person_id + 1
      @@current_person_id
    end
  end
end

class GroupId
  @@current_group_id = 0
  class << self
    def get_new_id
      @@current_group_id = @@current_group_id + 1
      @@current_group_id
    end
  end
end
class Groups
  @@overall_groups = []

  class << self
    def overall_groups
      @@overall_groups
    end
    def add_group(group)
      @@overall_groups << group
    end
    def list_groups_and_members
      @@overall_groups.each{ |group|
        puts "Group #{group.group_id} has members "
        group.list_members
      }
    end
  end
end
class Group
  attr_accessor :group_id, :people_in_group

  def initialize
    @group_id = GroupId.get_new_id
    @people_in_group = []
    Groups.add_group self
  end

  def add_person(person)
    person.group = self
    @people_in_group << person
  end

  def remove_person(person)
    person.group = nil
    @people_in_group.delete(person)
  end

  def is_in_group?(person)
    if person.group == self
      return true
    else
      return false
    end
  end

  def list_members
    if @people_in_group.any?
      @people_in_group.each{ |member|
       puts member.name + " "
      }
    else
      puts "N/A"
    end
  end

end

class Person

  attr_accessor :friendships, :person_id, :name, :group

  def initialize(name)
    @person_id = PersonId.get_new_id
    @name = name
    @friendships = []
    @connected_to = []
    @group = nil
  end

  def set_friend_to_group(group)
    if !self.group.nil?
      @group.remove_person self
    end
    group.add_person self
  end

  def add_friend(new_friend)
    puts "Adding #{new_friend.name} to #{@name}'s friend list." if Debug.mode
    if !has_friend? new_friend

      # Are either friend in a group yet?
      # If so add friend
      # If not create new group
      if @group and new_friend.group
        puts "Both #{@name} and #{new_friend.name} are in groups." if Debug.mode
        if @group == new_friend.group
          # They're in the same group just not friends yet
          # Do nothing...
        else
          puts "#{@name} and #{new_friend.name} are in different groups." if Debug.mode
          puts "#{@name} in group #{@group.group_id} which has #{@group.people_in_group.length} people in it." if Debug.mode
          puts "#{new_friend.name} in group #{new_friend.group.group_id} which has #{new_friend.group.people_in_group.length} people in it." if Debug.mode
          # They're not in the same group, but are both in a group
          # Change theirs and their friends group
          # to current persons group recursively
          @connected_to = []
          if new_friend.group.people_in_group.length < @group.people_in_group.length
            recursively_change_friend_group(new_friend, @group)
          else
            recursively_change_friend_group(self, new_friend.group)
          end
        end
      elsif @group
        puts "#{@name} is in a group, but #{new_friend.name} (new) isn't." if Debug.mode
        new_friend.set_friend_to_group @group
      elsif new_friend.group
        puts "#{new_friend.name} (new) is in a group, but #{@name} isn't." if Debug.mode
        self.set_friend_to_group new_friend.group
      else
        puts "Neither #{new_friend.name} or #{@name} are in a group, adding..." if Debug.mode
        new_group = Group.new
        self.set_friend_to_group new_group
        new_friend.set_friend_to_group new_group
      end
      new_friend.friendships << self
      @friendships << new_friend
    end
  end

  def is_connected_to?(friend)
    if friend.group == @group
      return true
    else
      return false
    end
  end

  def recursively_change_friend_group(friend_to_change, group)
    if !@connected_to.include? friend_to_change.person_id
      puts "Changing #{friend_to_change.name}'s group to #{group.group_id}"
      friend_to_change.set_friend_to_group group
      @connected_to << friend_to_change.person_id
      friend_to_change.friendships.each{ |friend|
        recursively_change_friend_group(friend, group)
      }
    end
  end

  def check_connectedness_with(friend)
    if has_friend? friend and is_connected_to? friend
      puts "Is friends with and is connected to #{friend.name}"
    elsif is_connected_to? friend
      puts "Is connected to but not friends with #{friend.name}"
    else
      puts "Is in no way connected to #{friend.name}"
    end
  end

  def has_friend?(friend)
    if @friendships.include? friend
      return true
    else
      return false
    end
  end

  def remove_friend(friend)
    if has_friend? friend
      @friendships.delete(friend)
      friend.friendships.delete(self)
      if @friendships.empty?
        puts "#{name} has no more friends, removing from group."
        @group.remove_person self
        @group = nil
      end
      if friend.friendships.empty?
        puts "#{friend.name} has no more friends, removing from group."
        friend.group.remove_person friend
        friend.group = nil
      end
    end
  end

  def friend_names
    @friendships.each{ |friend|
      puts friend.name + " "
    }
  end

end

# Create some friends
sally = Person.new("Sally")
kyle = Person.new("Kyle")
stan = Person.new("Stan")
penelope = Person.new("Penelope")
mike = Person.new("Mike")

peter = Person.new("Peter")
paul = Person.new("Paul")


puts "---Sally friends with Kyle, Kyle friends with Stan---"

# Test against multiple loading
kyle.add_friend sally
kyle.add_friend sally

stan.add_friend kyle

puts "Sally group id: " + sally.group.group_id.to_s
puts "Kyle group id: " + kyle.group.group_id.to_s
puts "Stan group id: " + stan.group.group_id.to_s

puts "---Peter friends Paul---"

peter.add_friend paul

puts "Peter group id: " + peter.group.group_id.to_s
puts "Paul group id: " + paul.group.group_id.to_s

Debug.set_mode true

puts "---Kyle friends with Peter---"

kyle.add_friend peter

puts "Sally group id: " + sally.group.group_id.to_s
puts "Kyle group id: " + kyle.group.group_id.to_s
puts "Stan group id: " + stan.group.group_id.to_s
puts "Peter group id: " + peter.group.group_id.to_s
puts "Paul group id: " + paul.group.group_id.to_s

puts "---Checking connectedness of Paul and Sally---"
paul.check_connectedness_with sally

puts "---Checking Peter's friends---"
peter.friend_names
puts "Peter's group id: #{peter.group.group_id}"
puts "Paul's group id: #{paul.group.group_id}"
puts "---Unfriending Paul and Peter---"
peter.remove_friend paul
peter.friend_names
puts "Peter's group id: #{peter.group.group_id}"
puts "Paul's group: #{paul.group}"
puts "---Unfriending Kyle and Peter---"
peter.remove_friend kyle
peter.friend_names
puts "Peter's group: #{peter.group}"

Groups.list_groups_and_members

