/* 
 * Copyright (C) 2026 Jack Flusche <jackflusche@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

module coll #( parameter
    WIDTH_1 = 10,
    HEIGHT_1 = 10,
    WIDTH_2 = 10,
    HEIGHT_2 = 10
)
(
    input wire [9:0] s1x, s2x,
    input wire [8:0] s1y, s2y,
    output wire coll
);

    wire [9:0] dx = (s1x > s2x ? s1x - s2x : s2x - s1x);
    wire [8:0] dy = (s1y > s2y ? s1y - s2y : s2y - s1y);

    assign coll = (
        (dx * 2 <= (WIDTH_1 + WIDTH_2)) &&
        (dy * 2 <= (HEIGHT_1 + HEIGHT_2))
    ) ? 1'b1 : 1'b0;

endmodule
/* verilator lint_off DECLFILENAME */
module wincoll #( parameter
    S_WIDTH = 640,
    S_HEIGHT = 480,
    WIDTH = 10,
    HEIGHT = 10
)
(
    input wire [9:0] sx,
    input wire [8:0] sy,
    output wire coll_v, coll_h
);

    localparam W2 = WIDTH / 2;
    localparam H2 = HEIGHT / 2;

    assign coll_h = (sx <= W2 || sx >= S_WIDTH - W2);
    assign coll_v = (sy <= H2 || sy >= S_HEIGHT - H2);

endmodule
