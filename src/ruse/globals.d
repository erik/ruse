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

import ruse.types;
import ruse.bindings;

Binding loadGlobalBindings() {
    Binding binds = new Binding();
    
    binds.set("nil", new Symbol("nil"));
    binds.set("true", new Symbol("true"));
    binds.set("false", new Symbol("false"));
    
    binds.set("add", new Lambda(&add));
    
    return binds;
}

// core functions
private:

RuseObject add(Binding bind, RuseObject[] args) {
    double total = 0;
    foreach(RuseObject arg; args) {
        Numeric val = cast(Numeric)arg.eval(bind);
        total += val.value;
    }
    
    return new Numeric(total);
}
