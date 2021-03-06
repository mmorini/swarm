// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
// 
// The Swarm Development Group can be reached via our website at:
// http://www.swarm.org/

#import <tkobjc/Entry.h>
#import <tkobjc/global.h>
#include <misc.h> // abort

@implementation Entry

PHASE(Creating)

- createEnd
{
  [super createEnd];
  
  // create the Entry
  [globalTkInterp eval: "entry %s; %s configure -width 10 -relief sunken;",
                  widgetName, widgetName];
  [globalTkInterp eval: "%s configure -textvariable %s;",
                  widgetName, variableName];
  return self;
}

PHASE(Using)

- (void)setValue: (const char *)t
{
  [globalTkInterp eval: "%s delete 0 end; %s insert 0 {%s}; %s xview 0",
		  widgetName, widgetName, t, widgetName];
}

- (const char *)getValue
{
  [globalTkInterp eval: "%s get", widgetName];

  return [globalTkInterp result];
}

- (void)setHeight: (unsigned)h
{
  abort ();
}

@end

