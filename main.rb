require 'fox16'
include Fox
class FileExplorer < FXMainWindow
	def initialize(app)
		super(app, "File Explorer", :width => 600, :height => 400)
		# Create a vertical layout to hold widgets
		vframe = FXVerticalFrame.new(self, :opts => LAYOUT_FILL)
		# Create a tree view widget
		tree = FXTreeList.new(vframe, :opts => LAYOUT_FILL)
		# Create a file list widget
		file_list = FXList.new(vframe, :opts => LAYOUT_FILL)
		# Add a tree item representing the root directory
		root_item = tree.addItemLast(nil, "/", nil, nil, Fox::TREEITEM_ROOT)
		# Populate the tree with directory structure
		populate_tree(root_item)
		# Handle tree item selection
		tree.connect(SEL_SELECTED) do
			selected_item = tree.currentItem
			if selected_item
				directory_path = selected_item.text(0)
				populate_file_list(directory_path, file_list)
			end
		end
		# Handle file double-click
		file_list.connect(SEL_DOUBLECLICKED) do
			selected_file = file_list.getItemText(file_list.currentItem)
			open_file(selected_file)
		end
		# Create a popup menu for renaming files
		menu = FXMenuPane.new(self)
		rename_cmd = FXMenuCommand.new(menu, "Rename...")
		file_list.connect(SEL_RIGHTBUTTONPRESS) do |sender, sel, event|
			menu.handle(self, event.root_x, event.root_y)
		end
		# Handle rename menu command
		rename_cmd.connect(SEL_COMMAND) do
			selected_file = file_list.getItemText(file_list.currentItem)
			rename_file(selected_file, file_list)
		end
	end
	def populate_tree(parent_item)
		directory_path = parent_item.text(0)
		Dir.glob(directory_path + "/*") do |entry|
			if File.directory?(entry)
				FXTreeItem.new(parent_item, File.basename(entry), nil, nil, Fox::TREEITEM_NORMAL)
			end
		end
	end
	def populate_file_list(directory_path, file_list)
		file_list.clearItems
		Dir.glob(directory_path + "/*") do |entry|
			if File.file?(entry)
				file_list.appendItem(File.basename(entry))
			end
		end
	end
	def open_file(file_name)
		if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
			system("start \"\" \"#{file_name}\"")
		elsif RbConfig::CONFIG['host_os'] =~ /linux/
			system("xdg-open \"#{file_name}\"")
		end
	end
	def rename_file(file_name, file_list)
		dialog = FXInputDialog.new(self, "Rename File", "Enter a new name for the file:")
		if dialog.execute != 0
			new_name = dialog.getText
			# Rename the file
			File.rename(file_name, File.dirname(file_name) + "/" + new_name)
			populate_file_list(File.dirname(file_name), file_list)
		end
	end
	def create
		super
		show(PLACEMENT_SCREEN)
	end
end
# Create the FXApp instance
app = FXApp.new
# Create the main window
FileExplorer.new(app)
# Run the application
app.create
app.run
