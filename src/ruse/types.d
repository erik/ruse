//      types.d
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

module ruse.types;
import ruse.bindings;

class RuseObject {
    
    //can't use opEquals, need Binding param :(
    override bool opEquals(Object o) {
        auto ro = cast(RuseObject)o;
        // TODO: bindings
        return ro.value() == this.value();
    }
    
    RuseObject eval(Binding bind) {
        return this;
    }
    
    RuseObject value() {
        return this;
    }
    
    string toString() {
        return "TODO: RuseObject#toString()";
    }

}

/* TODO: Some more stuff should probably be derived from Atom instead of RuseObject */

class Atom : RuseObject {
    this(RuseObject value) {
        this.value = value;
    }
    
    override string toString() {
        return value.toString();
    }
    
    private: 
    RuseObject value;
}

class List : RuseObject {
    this(RuseObject[] arr) {
        this.values = arr;
    }
    
    this() {
        this.values = [];
    }
    
    RuseObject car() {
        if(values.length > 0) {
            return values[0];
        }
        else {
            //TODO: return nil instead
            return new RuseObject();
        }
    }
    
    List cdr() {
        if (values.length) {
            return new List(values[1..$]);
        }
        
        else {
            //TODO: return nil instead
            return new List();
        }
    }
    
    override string toString() {
        if(this.values.length) {
            string str = "(";
            foreach(RuseObject x; values) {
                str ~= x.toString() ~ " ";
            }
            return str ~ "\b)";
        }
        else {
            return "()";
        }
    }
    
    override RuseObject eval(Binding bind) {
        if(values.length) {
            //TODO: + .call(bind, this.cdr)
            return this.car().eval(bind);
        }
        else {
            //TODO: return nil instead
            return new RuseObject();
        }
    }
    
    private:
    RuseObject[] values;
}

class Character : RuseObject {
    this(char c) {
        this.value = c;
    }
    
    override string toString() {
        string val;
        
        switch(value) {
            case '\n':
                val = "newline";
                break;
            case '\r':
                val = "return";
                break;
            case '\t':
                val = "tab";
                break;
            default:
                val = "" ~ value;
        }
        return "\\" ~ val;
    }
    
    protected:
    char value;
}

class String : RuseObject {
    this(string value) {
        this.value = value;
    }
    
    Character car() {
        if(this.value.sizeof) {
            return new Character(this.value[0]);
        }
        else {
            // TODO: return nil instead
            return new Character(' ');
        }
    }
    
    String cdr() {
        // TODO: handle empty strings, all that good stuff
        return new String(this.value[1..$]);
    }
    
    override string toString() {
        return '"' ~ this.value ~ '"';
    }
    
    protected:
    string value;
}

class Symbol : RuseObject {
    this(string value) {
        this.value = value;
    }
    
    override string toString() {
        return value;
    }
    
    override RuseObject eval(Binding bind) {
        return bind.get(value);
    }
    
    protected:
    string value;
}

class Keyword : RuseObject {
    this(string value) {
        this.value = value;
    }
    
    //TODO: equality
    
    override string toString() {
        return ":" ~ value;
    }
    
    protected:
    string value;
}

class Numeric : RuseObject {
    this(double value) {
        this.value = value;
    }
    
    RuseObject eval() {
        return this;
    }
    
    override string toString() {
        //TODO: text probably isn't the accepted way of doing this
        return std.conv.text(value);
    }
    
    private:
    double value;
}

class Lambda : RuseObject {
    //TODO: Implement lambda class
}

class Macro : Lambda {
    //TODO: Implement macro class
}
