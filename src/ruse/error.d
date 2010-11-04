//      error.d
//      
//      Copyright 2010 Erik Price <erik <dot> price16 <at> gmail <dot> com>
//      
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//      
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//      
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.

module ruse.error;

// collection of ruse error classes

class RuseError {
    public string message;
    
    this(string s) {
        message = s;
    }
    
    this() {
        message = "an error occured!";
    }
}

class SyntaxError : RuseError {
    this(string s) {
        message = s;
    }
}

class EOFError : RuseError {
    this(string s) {
        message = s;
    }
}

class UndefinedSymbolError : RuseError {
    this(string s) {
        message = s;
    }
}

class ArgumentError : RuseError {
    this(string s) {
        message = s;
    }
}

class IncompatibleTypesError : RuseError {
    this(string s) {
        message = s;
    }
}
