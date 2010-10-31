//      bindings.d
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

module ruse.bindings;

import std.stdio;
import std.conv;

import ruse.types;
import ruse.error;

class Binding {
    
    this() {
        this.parents = null;
    }
    
    this(Binding[] parents ...) {
        foreach(Binding parent; parents) {
            this.parents ~= parent;
        }
    }
    
    void set(string name, RuseObject value) {
        this.bindings[name] = value;
    }
    
    RuseObject get(string name) {
        // yes! pointers! ಠ_ಠ
        RuseObject *val = name in this.bindings;
        if(val == null && this.parents != null) {
            foreach(Binding parent; parents) {
                *val = parent.get(name);
                if(val != null) {
                    return *val;
                }
            }
        } else if(val == null && this.parents == null) {
            throw new UndefinedSymbolError(text("Undefined symbol: ",
                name));
        }
        return *val;
    }
    
    private:
     RuseObject[string] bindings;
     Binding[] parents;    
}
