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
import ruse.error;
import std.conv;
import std.string;

enum RuseType {
    BLANK,
    ATOM,
    LIST,
    CHARACTER,
    STRING,
    SYMBOL,
    KEYWORD,
    NUMERIC,
    LAMBDA,
    MACRO
}

class RuseObject {
    
    this() {
        this.type_ = RuseType.BLANK;
    }
    
    RuseObject car() {
        throw new SyntaxError("can't call 'car' on value " ~ this.toString);
    }

    RuseObject cdr() {
        throw new SyntaxError("can't call 'cdr' on value " ~ this.toString);
    }
    
    RuseObject call(Binding bind, RuseObject[] args) {
        throw new SyntaxError("can't call a non lambda!");
    }
    
    RuseObject eval(Binding bind) {
        return this;
    }
    
    RuseObject value() {
        return this;
    }
    
    bool boolValue() {
        if(this.type == RuseType.SYMBOL) {
            Symbol tmp = cast(Symbol)this;
            if(tmp.value == "false" || tmp.value == "nil") {
                return false;
            }
            else {
                return true;
            }
        }
        
        // everything else is true
        return true;
    }
    
    string toString() {
        return "<you shouldn't have seen this...>";
    }
    
    @property RuseType type() { return type_; }
    @property RuseType type(RuseType t) { return type_ = t; }

    bool isType(RuseType type) {
        return this.type_ == type;
    }
    
    protected:
        RuseType type_;
    
}

class List : RuseObject {
    this(RuseObject[] arr) {
        this.values = arr;
        this.type_ = RuseType.LIST;
    }
    
    this() {
        this.values = [];
        this.type_ = RuseType.LIST;
    }
    
    RuseObject eval(Binding bind) {
        
        RuseObject fn = this.car().eval(bind);
        RuseObject[] args = this.values.length ? this.values[1..$] :
            [];
        return fn.call(bind, args);
    }
    
    RuseObject car() {
        if(values.length > 0) {
            return values[0];
        }
        else {
            return new Symbol("nil");
        }
    }
    
    List cdr() {
        if (values.length) {
            return new List(values[1..$]);
        }
        
        else {
            return new Symbol("nil");
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
    
    @property int length() { return this.values.length; }

    RuseObject[] values;
}

class Character : RuseObject {
    this(char c) {
        this.value = c;
        this.type_ = RuseType.CHARACTER;
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
        this.type_ = RuseType.STRING;
    }
    
    Character car() {
        if(this.value.length) {
            return new Character(this.value[0]);
        }
        else {
            return new Symbol("nil");
        }
    }
    
    String cdr() {
        if(this.value.length > 1) {
            return new String(this.value[1..$]);
        }
        else {
            return new Symbol("nil");
        }
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
        this.type_ = RuseType.SYMBOL;
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
        this.type_ = RuseType.KEYWORD;
    }

    override string toString() {
        return ":" ~ value;
    }
    
    protected:
    string value;
}

class Numeric : RuseObject {
    this(double value) {
        this.value = value;
        this.type_ = RuseType.NUMERIC;
    }
    
    RuseObject eval() {
        return this;
    }
    
    override string toString() {
        return std.conv.text(value);
    }
    
    double value;
}

// returns RuseObject, takes (Binding bindings, RuseObject[] args)
alias RuseObject function(Binding, RuseObject[]) CoreFunction;

class Lambda : RuseObject {
   
    this(List args, List bod) {
        this.core = false;
        this.args = args;
        this.bod = bod;
        this.corefunc = null;
        this.type_ = RuseType.LAMBDA;
    }
    
    // built in function
    this(CoreFunction func) {
        this.core = true;
        this.args = null;
        this.bod = null;
        this.corefunc = func;
        this.type_ = RuseType.LAMBDA;
    }
    
    override string toString() {
        if(!core) {
            return "(fn " ~ this.args.toString()
                ~ " " ~ this.bod.toString() ~ ")";
        }
        
        return text("#<core fn ", corefunc, ">"); 
    }
    
    override Lambda eval(Binding b) {
        return this;
    }
    
    override RuseObject call(Binding bind, RuseObject[] args) {
        return this.core ? callCore(bind, args) : callRuse(bind, args);
    }
    
    protected:
    
    RuseObject callCore(Binding bind, RuseObject[] args) {
        return this.corefunc(bind, args);
    }

    
    RuseObject callRuse(Binding bind, RuseObject[] args) {
        Binding local = new Binding(bind);    
        
        if(args.length != this.args.length) {
            throw new ArgumentError(text("wrong number of arguments ",
                args.length, " for ", this.args.length));
        }
        
        for(int i = 0; i < this.args.length; ++i) {
            local.set(this.args.values[i].toString, args[i].eval(bind));
        }
        return this.bod.eval(local);
    }
    
    // core (D) function?
    bool core;
    List args;
    List bod;
    CoreFunction corefunc;
}

/* TODO: write Macro class
class Macro : Lambda {
    this() {
        this.type_ = RuseType.MACRO;
    }
}*/
