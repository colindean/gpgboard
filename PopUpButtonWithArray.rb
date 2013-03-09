#
#https://bitbucket.org/codefriar/macruby-recipes/raw/9c799aa3b2e385dd1861fa821fc50f5a29460450/PopUp_button_with_array.rb
class PopUpButtonWithArray
    #-- Goal: A class demonstrating how to populate a NSPopUpButton (drop down menu button)
    #---- and how to access the user's selection.
    
	attr_accessor :button_handle, :selected_item
    
	def initialize(handle, options)
		raise "Cannot instantiate NSPopUpButton without option array" unless options.is_a? Array
		@options = options.sort #always nice to present your options in alphabetical order to the user but totally optional
		self.button_handle = handle #assign our IB outlet handle from the NSPopUpButton to this instance.
		reset
		populate
	end
	
	def get_selected
        @button_handle.titleOfSelectedItem #snags the title of the selected item.
    end
    
	def reset
		@button_handle.removeAllItems #as expected this removes everything from the list, including the default item 1, item 2 ...
	end
    
	def populate
		@button_handle.addItemsWithTitles @options
		#-- This is functionally identical to running this block:
		## @options.each {|x| @button_handle.addItemWithTitle(x)}
	end
    
    #-- You can utilize this class thusly:
    ## Button = PopUpButtonWithArray.new(@ibHandle_To_NSPopUpButton, array_of_options) #to setup the button's options
    ## User_chose = Button.get_selected #get the user selection.
end