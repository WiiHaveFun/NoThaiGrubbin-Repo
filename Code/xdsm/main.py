from pyxdsm.XDSM import XDSM, OPT, SUBOPT, SOLVER, FUNC, IFUNC, LEFT

if __name__ == '__main__':
    # Change `use_sfmath` to False to use computer modern
    x = XDSM(use_sfmath=True)

    # Systems
    x.add_system("human", OPT, r"\text{Manual Iteration}")
    x.add_system("W", IFUNC, r"\text{Weight Estimation}")
    x.add_system("SP", FUNC, r"\text{Sizing Constraints}")
    x.add_system("wing", SUBOPT, r"\text{Wing Planform Sizing}")
    x.add_system("AF", SUBOPT, r"\text{Airfoil Optimization}")
    x.add_system("tail", SUBOPT, r"\text{Tail Sizing}")
    x.add_system("AVL", FUNC, r"\text{AVL}")
    x.add_system("RFP", FUNC, r"\text{RFP Constraints}")

    # Processes
    x.add_process(["human", "W", "SP", "human"], arrow=True)
    x.add_process(["W", "wing", "AVL", "wing"], arrow=True)
    x.add_process(["wing", "tail", "AVL", "tail"], arrow=True)
    x.add_process(["wing", "AF", "wing"], arrow=True)
    x.add_process(["wing", "RFP", "human"], arrow=True)
    x.add_process(["tail", "RFP", "human"], arrow=True)

    # Connections
    # Preliminary Sizing
    x.connect("human", "W", [r"x_{\text{aircraft}}", r"x_{\text{mission}}"])
    x.connect("human", "SP", [r"x_{\text{aircraft}}", r"x_{\text{mission}}"])
    x.connect("W", "SP", r"y_{\text{weights}}")
    x.connect("SP", "human", r"c_{\text{sizing}}")
    # Wing
    x.connect("human", "wing", [r"x_{\text{aircraft}}", r"x_{\text{mission}}"])
    x.connect("W", "wing", r"y_{\text{weights}}")
    x.connect("W", "AVL", r"y_{\text{weights}}")
    x.connect("wing", "AVL", r"y_\text{wing}")
    x.connect("AVL", "wing", r"f_\text{cruise}")
    # Airfoil
    x.connect("human", "AF", r"x_{\text{mission}}")
    x.connect("W", "AF", r"y_{\text{weights}}")
    x.connect("wing", "AF", r"y_\text{wing}")
    x.connect("AF", "wing", [r"f_\text{airfoil}", r"y_\text{airfoil}"])
    # Tail
    x.connect("wing", "tail", r"y_\text{wing}")
    x.connect("tail", "AVL", r"y_\text{tail}")
    x.connect("AVL", "tail", r"c_\text{tail}")
    # RFP Constraints
    x.connect("human", "RFP", [r"x_{\text{aircraft}}", r"x_{\text{mission}}"])
    x.connect("W", "RFP", r"y_{\text{weights}}")
    x.connect("wing", "RFP", r"y_\text{wing}")
    x.connect("tail", "RFP", r"y_\text{tail}")
    x.connect("RFP", "human", r"c_\text{RFP}")

    # Outputs
    x.add_output("human", [r"x_{\text{aircraft}}^*", r"x_{\text{mission}}^*"], side=LEFT)
    x.add_output("W", r"y_{\text{weights}}^*", side=LEFT)
    x.add_output("wing", r"y_\text{wing}^*", side=LEFT)
    x.add_output("tail", r"y_\text{tail}^*", side=LEFT)
    x.add_output("AF", r"y_\text{airfoil}^*", side=LEFT)

    # x.add_input("W_TO", r"b, S_{ref}, \text{Mission Parameters}")

    # x.connect("W_TO", "D1", "x, z")

    x.write("xdsm_pdr")
    # x.add_system("opt", OPT, r"\text{Optimizer}")
    # x.add_system("solver", SOLVER, r"\text{Newton}")
    # x.add_system("D1", FUNC, "D_1")
    # x.add_system("D2", FUNC, "D_2")
    # x.add_system("F", FUNC, "F")
    # x.add_system("G", FUNC, "G")
    #
    # x.connect("opt", "D1", "x, z")
    # x.connect("opt", "D2", "z")
    # x.connect("opt", "F", "x, z")
    # x.connect("solver", "D1", "y_2")
    # x.connect("solver", "D2", "y_1")
    # x.connect("D1", "solver", r"\mathcal{R}(y_1)")
    # x.connect("solver", "F", "y_1, y_2")
    # x.connect("D2", "solver", r"\mathcal{R}(y_2)")
    # x.connect("solver", "G", "y_1, y_2")
    #
    # x.connect("F", "opt", "f")
    # x.connect("G", "opt", "g")
    #
    # x.add_output("opt", "x^*, z^*", side=LEFT)
    # x.add_output("D1", "y_1^*", side=LEFT)
    # x.add_output("D2", "y_2^*", side=LEFT)
    # x.add_output("F", "f^*", side=LEFT)
    # x.add_output("G", "g^*", side=LEFT)
