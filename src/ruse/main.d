//      main.d
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

module ruse.main;

import std.stdio;
import std.string;

import ruse.types;
import ruse.reader;
import ruse.bindings;
import ruse.globals;
import ruse.error;
import ruse.readline;

int main(string[] args)
{
    
    const string prompt = "> ";
    Reader r;
    string src;
    Binding bind = loadGlobalBindings();
    
    // TODO: better command line handling
    if(args.length > 1) {
        for(int i = 1; i < args.length ; ++i) {
            switch(args[i]) {
                case "-e":
                    args = i == args.length - 1 ? args ~ "" : args;
                    foreach(RuseObject exp; (new Reader(args[++i])).read()) {
                        writeln(exp.eval(bind).toString());
                    }
                    break;
                default:
                writeln("Don't know switch: " ~ args[i]);
                return 1;
            }
        }
        
        return 0;
    }
    
    src = readLine(prompt);
    
    while(true) {
        
        r = new Reader(src);
        try {
            RuseObject[] exprs = r.read();
            
            foreach(RuseObject exp; exprs) {
                RuseObject val = exp.eval(bind);
                writeln(val.toString());
            }
        } 
        catch (EOFError e) {
            src ~= readLine(prompt);
            continue;
        }           
        catch (RuseError e) {
            writeln(e, ": " ~ e.message);
        }
        addHistory(src);
        src = readLine(prompt);
    }        
    
    return 0;
}

