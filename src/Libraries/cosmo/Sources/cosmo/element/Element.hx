package cosmo.element;

import jasper.Variable;
import jasper.Constraint;
import jasper.Solver;
import cosmo.style.Style;

class Element
{
    public static var solver (default, null) = new Solver();

    public var firstChild (default, null) : Element;
    public var nextSibling (default, null) : Element;
    public var parentElement (default, null) : Element;

    public var x :Variable;
    public var y :Variable;
    public var width :Variable;
    public var height :Variable;
    public var style :Style;

    public function new(style :Style) : Void
    {
        x = new Variable();
        y = new Variable();
        width = new Variable();
        height = new Variable();
        this.style = style;
    }

    public function draw(framebuffer :kha.Framebuffer) : Void
    {
        framebuffer.g2.color = style.color;
        framebuffer.g2.fillRect(x, y, width, height);
    }

    public function onUp(x :Int, y :Int) : Void
    {
    }

    public function onDown(x :Int, y :Int) : Void
    {
    }

    public function onMove(x :Int, y :Int) : Void
    {
    }

    public function appendChild(child :Element) : Element
    {
        if (child.parentElement != null) {
            child.parentElement.removeChild(child);
        }
        child.parentElement = this;
        child.layout(this);

        var tail = null, p = firstChild;
        while (p != null) {
            tail = p;
            p = p.nextSibling;
        }
        if (tail != null) {
            tail.nextSibling = child;
        } else {
            firstChild = child;
        }

        return this;
    }

    public function removeChild(child :Element) : Void
    {
        var prev :Element = null, p = firstChild;
        while (p != null) {
            var nextSibling = p.nextSibling;
            if (p == child) {
                // Splice out the entity
                if (prev == null) {
                    firstChild = nextSibling;
                } else {
                    prev.nextSibling = nextSibling;
                }
                p.parentElement = null;
                p.nextSibling = null;
                child.clean();
                return;
            }
            prev = p;
            p = nextSibling;
        }
    }

    public function replaceChild(newChild :Element, oldChild :Element) : Void
    {
        if (newChild.parentElement != null) {
            newChild.parentElement.removeChild(newChild);
        }
        newChild.parentElement = this;

        var prev :Element = null, p = firstChild;
        while (p != null) {
            var nextSibling = p.nextSibling;
            if (p == oldChild) {
                // Splice out the entity
                if (prev == null) {
                    firstChild = newChild;
                } else {
                    prev.nextSibling = newChild;
                }
                newChild.nextSibling = nextSibling;
                newChild.parentElement = this;

                p.parentElement = null;
                p.nextSibling = null;
 
                swapVars(newChild, oldChild);
                return;
            }

            prev = p;
            p = nextSibling;
        }
    }

    private function layout(parent :Element) : Void
    {
        _constraints = [];
        
        switch(parent.style.direction) {
            case VERTICAL: {
                _constraints.push(this.x == parent.x);

                if((parent.firstChild == null)) {
                    _constraints.push(this.y == parent.y);
                }
                else {
                    var lastChild = parent.lastChild();
                    _constraints.push(this.y == (lastChild.y + lastChild.height));
                }
            }
            case HORIZONTAL: {
                _constraints.push(this.y == parent.y);

                if((parent.firstChild == null)) {
                    _constraints.push(this.x == parent.x);
                }
                else {
                    var lastChild = parent.lastChild();
                    _constraints.push(this.x == (lastChild.x + lastChild.width));
                }
            }
        }

        switch this.style.width {
            case INHERIT:
            case PX(val): _constraints.push(this.width == val);
            case FUNC(val):
        }

        switch this.style.height {
            case INHERIT:
            case PX(val): _constraints.push(this.height == val);
            case FUNC(val):
        }

        for(c in _constraints) {
            solver.addConstraint(c);
        }

        solver.updateVariables();
    }

    private function lastChild() : Element
    {
        if(this.firstChild != null) {
            var p = this.firstChild;
            var cur = p;
            while(p != null) {
                cur = p;
                p = p.nextSibling;
            }
            return cur;
        }
        return null;
    }

    private function clean() : Void
    {
        for(c in _constraints) {
            solver.removeConstraint(c);
        }
        _constraints = [];
    }

    private function swapVars(newChild :Element, oldChild :Element) : Void
    {
        var newChildX = newChild.x;
        var newChildY = newChild.y;
        var newChildWidth = newChild.width;
        var newChildHeight = newChild.height;

        newChild.x = oldChild.x;
        newChild.y = oldChild.y;
        newChild.width = oldChild.width;
        newChild.height = oldChild.height;

        oldChild.x = newChildX;
        oldChild.y = newChildY;
        oldChild.width = newChildWidth;
        oldChild.height = newChildHeight;
    }

    private var _constraints :Array<Constraint>;
}