//      reader.d
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

module ruse.reader;
import ruse.types;

import std.conv;
import std.string;

import std.stdio;

class Reader {
    
    this(string source) {
        this.source = source;
        this.lineNum = 1;
        this.index = 0;
    }
    
    char current() {
        // TODO: throw exception if out of bounds
        return this.source[this.index];
    }
    
    char next() {
        this.index++;
        return this.current();
    }
    
    char prev() {
        this.index--;
        return this.current();
    }
    
    RuseObject[] read() {
        RuseObject[] expr = [];

        while (this.index < this.source.length - 1) {
            writeln("this.current = " ~ this.current());
            // skip over whitespace
            if(iswhite(this.current())) {
                if(this.current == '\n') {
                    this.lineNum++;
                }
            }
            
            // skip over comments
            else if(this.current == ';') {
                // read to end of line
                while(this.next != '\n') {}
                this.lineNum++;
            }
            
            // read number
            // TODO: Negative numbers
            else if(isNumeric(this.current)) {
                expr ~= this.readNumber();
            }
            
            this.next();
        }
        return expr;
    }
    
    Numeric readNumber() {
        string num = "";
        num ~= this.current;
        
        while(!isDelim(this.next)) {
            num ~= this.current;
        }
        
        this.prev;
        
        // TODO: parse will probably throw an exception or otherwise 
        //    complain when given bad input
        return new Numeric(parse!(double)(num));
    }    
    
    private:
    
    bool isDelim(char c) {
        if(iswhite(c))
            return true;
        foreach(char delim; delims) {
            if(c == delim) {
                return true;
            }
        }
        return false;
    }
    
    int lineNum;
    string source;
    int index;
    char[] delims = ['(', ')'];
}
