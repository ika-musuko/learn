use std::arch::x86_64::*;
use std::f64::consts::PI;
use std::mem;

#[repr(C)]
struct Body {
    position: [f64; 3],
    velocity: [f64; 3],
    mass: f64,
}

const SOLAR_MASS: f64 = 4. * PI * PI;
const DAYS_PER_YEAR: f64 = 365.24;
const BODIES_COUNT: usize = 5;

static mut SOLAR_BODIES: [Body; BODIES_COUNT] = [
    Body {
        mass: SOLAR_MASS,
        position: [0.; 3],
        velocity: [0.; 3],
    },
    Body {
        // Jupiter
        position: [
            4.84143144246472090e+00,
            -1.16032004402742839e+00,
            -1.03622044471123109e-01,
        ],
        velocity: [
            1.66007664274403694e-03 * DAYS_PER_YEAR,
            7.69901118419740425e-03 * DAYS_PER_YEAR,
            -6.90460016972063023e-05 * DAYS_PER_YEAR,
        ],
        mass: 9.54791938424326609e-04 * SOLAR_MASS,
    },
    Body {
        // Saturn
        position: [
            8.34336671824457987e+00,
            4.12479856412430479e+00,
            -4.03523417114321381e-01,
        ],
        velocity: [
            -2.76742510726862411e-03 * DAYS_PER_YEAR,
            4.99852801234917238e-03 * DAYS_PER_YEAR,
            2.30417297573763929e-05 * DAYS_PER_YEAR,
        ],
        mass: 2.85885980666130812e-04 * SOLAR_MASS,
    },
    Body {
        // Uranus
        position: [
            1.28943695621391310e+01,
            -1.51111514016986312e+01,
            -2.23307578892655734e-01,
        ],
        velocity: [
            2.96460137564761618e-03 * DAYS_PER_YEAR,
            2.37847173959480950e-03 * DAYS_PER_YEAR,
            -2.96589568540237556e-05 * DAYS_PER_YEAR,
        ],
        mass: 4.36624404335156298e-05 * SOLAR_MASS,
    },
    Body {
        // Neptune
        position: [
            1.53796971148509165e+01,
            -2.59193146099879641e+01,
            1.79258772950371181e-01,
        ],
        velocity: [
            2.68067772490389322e-03 * DAYS_PER_YEAR,
            1.62824170038242295e-03 * DAYS_PER_YEAR,
            -9.51592254519715870e-05 * DAYS_PER_YEAR,
        ],
        mass: 5.15138902046611451e-05 * SOLAR_MASS,
    },
];

fn offset_momentum(bodies: &mut [Body; BODIES_COUNT]) {
    //for i in 0..BODIES_COUNT {
    for body in bodies {
        for velocity_dimension in &mut body.velocity {
            //(*bodies.add(0)).velocity[m] -=
            //    (*bodies.add(i)).velocity[m] * (*bodies.add(i)).mass / SOLAR_MASS;
            (*velocity_dimension) -= (*velocity_dimension) * body.mass / SOLAR_MASS;
        }
    }
}

unsafe fn output_energy(bodies: *mut Body) {
    let mut energy = 0.;
    for i in 0..BODIES_COUNT {
        // add kinetic energy for each body
        energy += 0.5
            * (*bodies.add(i)).mass
            * ((*bodies.add(i)).velocity[0] * (*bodies.add(i)).velocity[0]
                + (*bodies.add(i)).velocity[1] * (*bodies.add(i)).velocity[1]
                + (*bodies.add(i)).velocity[2] * (*bodies.add(i)).velocity[2]);

        // add potential energy between this body and every other body
        for j in i + 1..BODIES_COUNT {
            let mut position_delta = [mem::MaybeUninit::<f64>::uninit(); 3];
            for m in 0..3 {
                position_delta[m]
                    .as_mut_ptr()
                    .write((*bodies.add(i)).position[m] - (*bodies.add(j)).position[m]);
            }
            let position_delta: [f64; 3] = mem::transmute(position_delta);

            energy -= (*bodies.add(i)).mass * (*bodies.add(j)).mass
                / f64::sqrt(
                    position_delta[0] * position_delta[0]
                        + position_delta[1] * position_delta[1]
                        + position_delta[2] * position_delta[2],
                );
        }
    }

    // output energy of system
    println!("{:.9}", energy);
}

unsafe fn advance(bodies: *mut Body) {
    const INTERACTIONS_COUNT: usize = BODIES_COUNT * (BODIES_COUNT - 1) / 2;
    const ROUNDED_INTERACTIONS_COUNT: usize = INTERACTIONS_COUNT + INTERACTIONS_COUNT % 2;

    // equivalent of C alignas(__m128d) double (align to a vector of 2 doubles)
    #[repr(align(16))]
    #[derive(Copy, Clone)]
    struct Align16([f64; ROUNDED_INTERACTIONS_COUNT]);

    static mut POSITION_DELTAS: [Align16; 3] = [Align16([0.; ROUNDED_INTERACTIONS_COUNT]); 3];
    static mut MAGNITUDES: Align16 = Align16([0.; ROUNDED_INTERACTIONS_COUNT]);

    // calculate distances
    {
        let mut k = 0; // total times in j loop
        for i in 0..BODIES_COUNT {
            for j in i + 1..BODIES_COUNT {
                for m in 0..3 {
                    POSITION_DELTAS[m].0[k] = // .0[k] is accessing (first) field in Align16 struct
                        (*bodies.add(i)).position[m]
                        - (*bodies.add(j)).position[m];
                }
                k += 1;
            }
        }
    }

    // compute gravitational interactions of each pair of bodies
    for i in 0..ROUNDED_INTERACTIONS_COUNT / 2 {
        let mut position_delta = [mem::MaybeUninit::<__m128d>::uninit(); 3];
        for m in 0..3 {
            position_delta[m]
                .as_mut_ptr()
                .write(*(&POSITION_DELTAS[m].0 as *const f64 as *const __m128d).add(i));
        }
        let position_delta: [__m128d; 3] = mem::transmute(position_delta);

        let distance_squared: __m128d = _mm_add_pd(
            _mm_add_pd(
                _mm_mul_pd(position_delta[0], position_delta[0]),
                _mm_mul_pd(position_delta[1], position_delta[1]),
            ),
            _mm_mul_pd(position_delta[2], position_delta[2]),
        );

        let mut distance_reciprocal: __m128d =
            _mm_cvtps_pd(_mm_rsqrt_ps(_mm_cvtpd_ps(distance_squared)));
        for _ in 0..2 {
            distance_reciprocal = _mm_sub_pd(
                _mm_mul_pd(distance_reciprocal, _mm_set1_pd(1.5)),
                _mm_mul_pd(
                    _mm_mul_pd(
                        _mm_mul_pd(_mm_set1_pd(0.5), distance_squared),
                        distance_reciprocal,
                    ),
                    _mm_mul_pd(distance_reciprocal, distance_reciprocal),
                ),
            );
        }

        (MAGNITUDES.0.as_mut_ptr() as *mut __m128d)
            .add(i)
            .write(_mm_mul_pd(
                _mm_div_pd(_mm_set1_pd(0.01), distance_squared),
                distance_reciprocal,
            ));
    }

    // update velocities
    {
        let mut k = 0;
        for i in 0..BODIES_COUNT - 1 {
            for j in i + 1..BODIES_COUNT {
                let i_mass_magnitude = (*bodies.add(i)).mass * MAGNITUDES.0[k];
                let j_mass_magnitude = (*bodies.add(j)).mass * MAGNITUDES.0[k];
                for m in 0..3 {
                    (*bodies.add(i)).velocity[m] -= POSITION_DELTAS[m].0[k] * j_mass_magnitude;
                    (*bodies.add(j)).velocity[m] += POSITION_DELTAS[m].0[k] * i_mass_magnitude;
                }
                k += 1;
            }
        }
    }

    for i in 0..BODIES_COUNT {
        for m in 0..3 {
            (*bodies.add(i)).position[m] += 0.01 * (*bodies.add(i)).velocity[m];
        }
    }
}

fn main() {
    unsafe {
        offset_momentum(&mut SOLAR_BODIES);
        output_energy(SOLAR_BODIES.as_mut_ptr());
        let c = std::env::args()
            .nth(1) // get first arg
            .unwrap() // panic on error
            .parse() // atoi
            .unwrap(); // panic on error
        for _ in 0..c {
            advance(SOLAR_BODIES.as_mut_ptr())
        }
        output_energy(SOLAR_BODIES.as_mut_ptr());
    }
}
