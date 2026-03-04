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

module sprite #( parameter
    WIDTH = 10,
    HEIGHT = 10
)
(
    input wire [9:0] x, y,
    input wire [9:0] sx,
    input wire [8:0] sy,
    output wire en
);

    assign en = (
        (x > sx - (WIDTH / 2) && x < sx + (WIDTH / 2)) &&
        (y > sy - (HEIGHT / 2) && y < sy + (HEIGHT / 2))
    );

endmodule
