/*
 * Copyright (c) 2018 Jeremy Meltingtallow
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package hxPaint.layout;

import jasper.Solver;
import jasper.Variable;
import hxPaint.element.Window;
import hxPaint.element.Rectangle;

class Layout
{
    public function new(window :Window) : Void
    {
        _solver = new Solver();
        _window = window;
    }

    public function initLayout() : Void
    {
        _solver.reset();
        solve_impl(_window, null, null, _solver);
        _solver.updateVariables();
        afterSolved_impl(_window);
    }

    public function updateLayout() : Void
    {
        _solver.updateVariables();
        afterSolved_impl(_window);
    }

    public function suggest(variable :Variable, value :Float) : Void
    {
        _solver.suggestValue(variable, value);
        _solver.updateVariables();
        afterSolved_impl(_window);
    }

    public static function solve_impl(rectangle :Rectangle, parent :Rectangle, prevSibling :Rectangle, solver :Solver)
    {
        rectangle.solve(solver, parent, prevSibling);

        var prevSibling :Rectangle = null;
        for(child in rectangle.children) {
            solve_impl(child, rectangle, prevSibling, solver);
            prevSibling = child;
        }
    }

     public static function afterSolved_impl(rectangle :Rectangle)
    {
        rectangle.afterSolved();

        for(child in rectangle.children) {
            afterSolved_impl(child);
        }
    }

    private var _solver :Solver;
    private var _window :Window;
}