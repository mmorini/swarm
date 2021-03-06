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

// Interface to BLT Graphs.  Legends, etc need to be handled more
// gracefully. Bindings to mouse (see BLT demos), autoscrolling, etc.
// should be added.

#import <tkobjc/Graph.h>
#import <tkobjc/global.h>
#import <collections.h> // List
#import <defobj.h> // STRDUP
#import <defobj/defalloc.h> // getZone
#include <misc.h> // atoi

@implementation Graph

PHASE(Creating)

- createEnd
{
  [super createEnd];
  
  [globalTkInterp eval: "graph %s;", widgetName];
  [self setWidth: 400 Height: 247];  // golden ratio
  // lots of features!
  [globalTkInterp eval: "Blt_ZoomStack %s; Blt_Crosshairs %s; Blt_ActiveLegend %s; Blt_ClosestPoint %s",
		  widgetName, widgetName, widgetName, widgetName];
  [self updateSize];
  elementList = [List create: getZone (self)];
  
  return self;
}

PHASE(Using)

- (void)setRangesXMin: (double)minx 
                  Max: (double)maxx
{
  [globalTkInterp 
    eval: "%s xaxis configure -min %f -max %f", widgetName, minx, maxx];
}

- (void)setRangesYMin: (double)miny
                  Max: (double)maxy 
{
  [globalTkInterp 
    eval: "%s yaxis configure -min %f -max %f", widgetName, miny, maxy];
}

- (void)setRangesXMin: (double)minx Max: (double)maxx
                 YMin: (double)miny Max: (double)maxy
{
  [self setRangesXMin: minx Max: maxx];
  [self setRangesYMin: miny Max: maxy];
}

- (void)setScaleModeX: (BOOL)xs Y: (BOOL)ys
{
  [globalTkInterp
    eval:
      "%s xaxis configure -loose %d; %s yaxis configure -loose %d",
    widgetName, (int)xs, widgetName, (int)ys];
}

- (id <GraphElement>)createElement
{
  id <GraphElement> newElement = [GraphElement createOwnerGraph: self];

  [elementList addLast: newElement];  

  return newElement;
}

- (void)destroyElement: (id <GraphElement>)g
{
  [elementList remove: g];
  [g drop];
}

- setTitle: (const char *)title
{
  [globalTkInterp eval: "%s configure -title {%s};", widgetName, title];
  [self setWindowTitle: title];
  return self;
}

- setAxisLabelsX: (const char *)xl Y: (const char *)yl
{
  [globalTkInterp
    eval:
      "%s xaxis configure -title {%s}; %s yaxis configure -title {%s};",
    widgetName, xl, widgetName, yl];
  return self;
}

- (void)pack
{
  [globalTkInterp eval: "pack %s -fill both -expand true;", widgetName];
}

// first destroy all the elements, then ourselves.
- (void)drop
{
  while ([elementList getCount] > 0)
    [self destroyElement: [elementList getFirst]];

  [super drop];
}

@end


@implementation GraphElement

PHASE(Creating)

- setOwnerGraph: (id <Graph>)og
{
  ownerGraph = og;

  return self;
}

// create ourselves and two vectors.
- createEnd
{
  if (ownerGraph == nil)
    raiseEvent (InvalidCombination, "This element has no owner graph!\n");
  name = STRDUP ([self getObjectName]);
  xData = [BLTVector create: getZone (self)];
  yData = [BLTVector create: getZone (self)];

  if ([globalTkInterp newBLTp])
    {
#if 0
      // Create a pen for a small, hollow circle.
      [globalTkInterp
        eval: "%s pen create %s_line -symbol circle -outlinewidth 1 -fill {} -pixels 0.05i",
        [ownerGraph getWidgetName],
        [self getName]];
#else
      // Create a pen for a wider line.
      [globalTkInterp
        eval: "%s pen create %s_line -symbol none -linewidth 3",
        [ownerGraph getWidgetName],
        [self getName]];
#endif
      
      // When inactive, use no symbol.  When active, use the new pen. 
      [globalTkInterp
        eval: "%s element create %s -xdata %s -ydata %s -symbol none -activepen %s_line",
        [ownerGraph getWidgetName],
        [self getName],
        [xData getName],
        [yData getName],
        [self getName]];
    }
  else
    // If we are using old BLT, only change line width.
    [globalTkInterp
      eval: "%s element create %s -xdata %s -ydata %s -symbol none -activelinewidth 3",
      [ownerGraph getWidgetName],
      [self getName],
      [xData getName],
      [yData getName],
      [self getName]];

  return self;
}

+ createOwnerGraph: (id <Graph>)og
{
  return [[[self createBegin: [og getZone]] setOwnerGraph: og] createEnd];
}

PHASE(Using)

- (void)drop
{
  if (![ownerGraph getDestroyedFlag])
    [globalTkInterp eval: "%s element delete %s",
                    [ownerGraph getWidgetName],
                    [self getName]];
  [xData drop];
  [yData drop];
  [super drop];
}

- (const char *)getName
{
  return name;
}

- (BLTVector *)getXData
{
  return xData;
}

- (BLTVector *)getYData
{
  return yData;
}

- (void)addX: (double)x Y: (double)y
{
  [xData append: x];
  [yData append: y];
}

- (void)resetData
{
  [xData resetData];
  [yData resetData];
}

- (void)setLabel: (const char *)label
{
  [globalTkInterp eval: "%s element configure %s -label {%s}",
                  [ownerGraph getWidgetName],
                  name,
                  label];
}

- (void)setColor: (const char *)color
{
  if ([globalTkInterp newBLTp])
    {
      [globalTkInterp eval: "%s element configure %s -color %s",
                      [ownerGraph getWidgetName],
                      name,
                      color];
      [globalTkInterp
        eval: "%s pen configure %s_line -color %s -outline %s",
        [ownerGraph getWidgetName],
        [self getName],
        color, color];
    }
  else
    [globalTkInterp
      eval: "%s element configure %s -color %s -activecolor %s",
      [ownerGraph getWidgetName],
      name,
      color, color];
}

- setWidth: (unsigned)w
{
  [globalTkInterp eval: "%s element configure %s -linewidth %u",
		  [ownerGraph getWidgetName], name, w];
  return self;
}

- (void)setSymbol: (const char *)s
{
  [globalTkInterp eval: "%s element configure %s -symbol %s",
		  [ownerGraph getWidgetName],
                  name,
                  s];
}

- (void)setSymbolSize: (unsigned)size
{
  [globalTkInterp eval: "%s element configure %s -pixels %u",
		  [ownerGraph getWidgetName],
                  name,
                  size];
}

// set the dash style - 0 means solid.
- (void)setDashes: (int)d
{
  [globalTkInterp eval: "%s element configure %s -dashes %d",
		  [ownerGraph getWidgetName],
                  name,
                  d];
}

@end

// replace this stuff with the BLT C API - should be much faster.
// also optimize append so it doesn't regrow the vector for every single
// value - regrow in chunks.
@implementation BLTVector

- createEnd
{
  name = STRDUP ([self getObjectName]);
  [globalTkInterp eval: "vector %s", name];
  return self;
}

- (const char *)getName
{
  return SSTRDUP (name);
}

- (unsigned)getLength
{
  [globalTkInterp eval: "%s length", name];
  return atoi ([globalTkInterp result]);
}

- (void)setLength: (unsigned)n
{
  [globalTkInterp eval: "%s length %u", name, n];
}

- (void)append: (double)v
{
  [globalTkInterp eval: "%s append %g", name, v];
}

// vector ranges - ":" is like the range "5:7", but it assumes you
// mean from min to max.
- (void)resetData
{
  [globalTkInterp eval: "%s delete :", name];
}

- (void)delete: (int)n
{
  [globalTkInterp eval: "%s delete %d", name, n];
}

- (void)drop
{
  [globalTkInterp eval: "unset %s", name];
}

@end

