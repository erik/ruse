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
import ruse.error;

import std.conv;
import std.string;

import std.stdio;

class Reader {
    
    this(string source) {
        this.source = source ~ "\n";
        this.lineNum = 1;
        this.index = 0;
    }
    
    char current() {
        // TODO: throw exception if out of bounds
        return this.source[this.index];
    }
    
    char next() {
        if(index + 1 >= this.source.length) {
            throw new EOFError(text("Unexpected EOF on line ", lineNum));
        }
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
            RuseObject exp = this.readCommon();
            if(exp !is null ) {
                expr ~= exp;
            }
            
            this.next();
        }
        return expr;
    }
    
    Numeric readNumber() {
        string num = "";
        num ~= this.current;

        bool dot = false;
        
        while(!isDelim(this.next)) {
            if(this.current == '.') {
                // only 1 dot allowed
                if(dot) {
                    throw new SyntaxError("Malformed number: `" 
                        ~ num ~ this.current ~ "'");
                }
                dot = true;
            }
            num ~= this.current;
        }
        
        this.prev;
        
        // TODO: check for valid numbers manually, parse("1.2abc") => 1.2
        return new Numeric(parse!(double)(num));
    }   
    
    String readString() {
        string str = "";
        
        while(this.next != '"') {
            str ~= this.current;
        }
        
        return new String(str);
    } 
    
    // TODO: more strict handling
    Keyword readKeyword(){
        string str = "";
        
        if(isDelim(this.next())) {
            throw new SyntaxError(text("line ", this.lineNum,
                ": Keyword can't be empty"));
        }
        this.prev();
        
        while(!isDelim(this.next)) {
            str ~= this.current();
        }
        
        if(isDelim(this.current)) {
            this.prev;
        }
        
        return new Keyword(str);
    }
    
    Symbol readSymbol() {
        string str = "" ~ this.current();
        
        while(!isDelim(this.next())) {
            str ~= this.current();
        }      
        
        if(isDelim(this.current)) {
            this.prev;
        }
        
        return new Symbol(str);
    }
    
    Character readCharacter() {
        char c = this.next();
        if(!isDelim(this.next())) {
            throw new SyntaxError(text(
                "line ", lineNum, ": can't have multichar character literal"));
        }
        this.prev();
        
        return new Character(c);
    }
    
    List readList() {
        RuseObject[] expr;
        
        while(this.next != ')') {
            RuseObject exp = this.readCommon();
            if(exp !is null ) {
                expr ~= exp;
            }
        }        
        return new List(expr);
    }
    
    private:
    
    // part of read function that is common to both read and readList
    RuseObject readCommon() {
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
                return null;
            }
            // read number
            // TODO: negative
            else if(this.isNumeric(this.current)) {
                return this.readNumber();
            }
            // read string
            else if(this.current == '"') {
                return this.readString();
            }
            // read keyword
            else if(this.current == ':') {
                return this.readKeyword();
            }
            // read character
            else if(this.current == '\\') {
                return this.readCharacter();
            }
            // quote
            else if(this.current == '\'') {
                this.next;
                return new List([new Symbol("quote"), this.readCommon()]);
            }
            else if(this.current == '(') {
                return this.readList();
            }
            
            else {
                return this.readSymbol();
            }
        return null;
    }
    
    bool isDelim(char c) {
        if(iswhite(c) || c == '\n')
            return true;
        foreach(char delim; delims) {
            if(c == delim) {
                return true;
            }
        }
        return false;
    }
    
    bool isNumeric(char c) {
        return inPattern(c, "0-9");
    }
    
    int lineNum;
    string source;
    int index;
    char[] delims = ['(', ')'];
}

