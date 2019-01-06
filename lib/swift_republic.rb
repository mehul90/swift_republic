# require 'pry'

#################################################################################

class Property 
	attr_accessor :associated_struct, :declaration_String
	attr_accessor :name, :type, :leading_spaces_count

	def initialize(struct, declaration_String)
		@associated_struct = struct
		indent_offset = declaration_String =~ /\S/ # Any non-whitespace character
		@leading_spaces_count = indent_offset
		@declaration_String = declaration_String.strip # Eg. "var sourceOfIncome: String"

		if declaration_String.include? ":"
			arr = declaration_String.split(":")
			name = arr.first.split(" ").last
			@name = name
			right_of_first_colon = arr.drop(1).join(":").strip
			@type = right_of_first_colon.split("//").first.strip
		else
			@name = "" 
			@type = ""
			p "Inferred types cannot be handled by the script -->  #{declaration_String}"
		end
	end
end

private
def create_initializer(properties_array)

	initStr = "\n"
	padding = " " * properties_array.first.leading_spaces_count # or use initStr.rjust(leading_spaces_count)
	initStr += padding
	initStr += "public init("

	# loop once to create "init(p1, p2, p3, ...) {"
	last_index = properties_array.size - 1
	properties_array.each_with_index { |property, index|
		initStr += property.name
		initStr += ": "
		initStr += property.type

		if index == last_index
			initStr += ") {\n"
		else
			initStr += ", "
		end
	}

	# loop again to append "self.p1 = p1\n"
	properties_array.each { |property|
		initStr += "#{padding}  self.#{property.name} = #{property.name}\n"
	}

	# append "}"
	initStr += "#{padding}}"

	# return string.
	initStr
end

#################################################################################

public
def make_models_public(source_file, destination_file, reserved_keywords = [])
	# source_file = "/A/B/C/D.swift"
	# destination_file = "/W/X/Y/Z.swift"

    lines = []
    bracket_stack = Array.new # keeps track of brackets... they must be balanced.
    struct_stack = Array.new # keeps track of latest struct containing current line.
    property_stack = Array.new
    protocol_stack = Array.new
    can_update_property_scope = false # helps in skipping updates to local variables.
    can_update_function_scope = true # helps in skipping updates to func inside protocols.
    # reserved_keywords = ["reserved_keywords or file names"] # skip ENTIRE FILES containing these keywords.

	file_name = File.basename(source_file)
	p "Parsing #{file_name} to output --> #{destination_file}"

	dirname = File.dirname(destination_file)
	unless File.directory?(dirname)
	  FileUtils.mkdir_p(dirname)
	end

	t_file = File.new(destination_file, "w")

	File.open(source_file) { |file|  
		lines = file.readlines
	}

	lines.each_with_index { |line, source_line_number|
		indent_offset = line =~ /\S/

		if reserved_keywords.any? { |keyword| line.include? keyword }
			t_file.close
			p "Could NOT parse #{file_name}. Dependencies/restricted keywords detected in line number #{source_line_number}: #{line}"
			File.delete(destination_file)
			break

		elsif (line.include? "private") || (line.include? "fileprivate") || (line.include? "public")
			if (line.include? "\{")
				if not (line.include? "\}")
					bracket_stack.push "other"
				end
			end				
			t_file.puts "#{line}"
			# Script is intended to handle only "internal" for now.

		elsif line.strip.start_with?("\/\/")
			# commented out code
			t_file.puts "#{line}"
			# pending check for /* XXX */

		elsif (line.include? "struct") && (line.include? "\{")
			line["struct"] = "public struct"		
			t_file.puts "#{line}"
			bracket_stack.push "#{line}"
			struct_stack.push "#{line}"

		elsif (line.include? "enum") && (line.include? "\{")
			line["enum"] = "public enum"
			t_file.puts "#{line}"
			bracket_stack.push line	 # doesn't need initilizer.

		elsif (line.include? "protocol ") && (line.include? "\{")
			line["protocol"] = "public protocol"
			t_file.puts "#{line}"
			bracket_stack.push line
			protocol_stack.push line

		elsif line.include? " func "
			if can_update_function_scope # if NOT in protocol:
				line["func"] = "public func"
			end
			if line.include? "\{"
				bracket_stack.push line
			end
			t_file.puts "#{line}"

		elsif can_update_property_scope && (line.strip.start_with?("let"))
			property_details = Property.new(struct_stack.last, line)
			property_stack.push property_details
			line.insert indent_offset, "public "
			t_file.puts "#{line}"

		elsif can_update_property_scope && (line.strip.start_with?("var"))
			property_details = Property.new(struct_stack.last, line)
			if line.strip.end_with?("\{")
				# computed property:
				bracket_stack.push line					
			else				
				property_stack.push property_details
			end
			line.insert indent_offset, "public "
			t_file.puts "#{line}"

		elsif can_update_property_scope && (line.strip.start_with?("static"))
			line.insert indent_offset, "public "
			t_file.puts "#{line}"
			if (line.include? "\{")
				if not (line.include? "\}")
					bracket_stack.push "other"
				end
			end

		elsif line.strip.start_with?("init(")
			line["init("] = "public init("
			if (line.include? "\{")
				if not (line.include? "\}")
					bracket_stack.push "other"
				end
			end
			t_file.puts "#{line}"

		elsif (line.include? "\{") # Eg. guard statements, etc.
			if not (line.include? "\}")
				bracket_stack.push "other"
			end
			t_file.puts "#{line}"

		elsif (line.strip.length == 1) && (line.include? "\}")
		# If end of struct, add its initializer.
			top_object = bracket_stack.pop
			if can_update_property_scope && (top_object.include? "struct")
				latest_struct = struct_stack.pop
				properties_array = Array.new

				while (property_stack.size > 0) && (property_stack.last.associated_struct == latest_struct)
					current_property = property_stack.pop
					properties_array.push current_property
				end

				if properties_array.size > 0
					# for structs which have both req and response inner structs
					# i.e. skip structs with no properties.
					struct_initializer = create_initializer(properties_array.reverse!)
					t_file.puts struct_initializer
				end

				t_file.puts "#{line}"
				# binding.pry
			elsif top_object.include? "protocol"
				protocol_stack.pop
				t_file.puts "#{line}"				
			else
				t_file.puts "#{line}"
			end

		elsif (line.include? "\}")
			bracket_stack.pop
			t_file.puts "#{line}   <<--Please fix formatting there, and run again."

		else
			t_file.puts "#{line}"
		end

		can_update_property_scope = (struct_stack.size > 0) && ((bracket_stack.last.include? "struct") || (bracket_stack.last.include? "enum")) # skip func and protocol
		can_update_function_scope = (protocol_stack.size == 0) # func in protocol are not to be made public.
	}

	t_file.close
end

public
def make_models_public_test(source_file, destination_file)
	p source_file
	p destination_file
end
