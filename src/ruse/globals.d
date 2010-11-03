//      globals.d
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

module ruse.globals;
import std.stdio;
import std.conv;

import ruse.types;
import ruse.bindings;
import ruse.error;

Binding loadGlobalBindings() {
    Binding binds = new Binding();
    
    binds.set("nil", new Symbol("nil"));
    binds.set("true", new Symbol("true"));
    binds.set("false", new Symbol("false"));
    
    binds.set("+", new Lambda(&add));
    
    binds.set("car", new Lambda(&car));
    binds.set("cdr", new Lambda(&cdr));
    
    binds.set("quote", new Lambda(&quote));
    
    return binds;
}

// core functions
private:

void checkArgs(string func, int expected, RuseObject[] args) {
    if(args.length != expected) {
        throw new ArgumentError("wrong number of arguments to "
            ~ func ~ " " ~ text(args.length) ~ " ~ for " ~ text(expected));
    }
}

RuseObject add(Binding bind, RuseObject[] args) {
    double total = 0;
    foreach(RuseObject arg; args) {
        Numeric val = cast(Numeric)arg.eval(bind);
        total += val.value;
    }
    
    return new Numeric(total);
}

RuseObject car(Binding bind, RuseObject args[]) {
    checkArgs("car", 1, args);
    
    return args[0].eval(bind).car();
}

RuseObject cdr(Binding bind, RuseObject args[]) {
    checkArgs("cdr", 1, args);
    
    return args[0].eval(bind).cdr();
}

RuseObject quote(Binding bind, RuseObject args[]) {
    checkArgs("quote", 1, args);
    
    return args[0];
}
