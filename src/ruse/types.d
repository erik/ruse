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
    
    this() {
    }
    
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
